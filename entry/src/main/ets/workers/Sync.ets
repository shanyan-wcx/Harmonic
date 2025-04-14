import { ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { i18n, intl } from '@kit.LocalizationKit';
import { getAlbum, getArtist, getArtistInfo, getIndexes, getPlaylists, getStarred, ping } from '../utils/Api';
import { Album, Artist, Playlist, Song } from '../utils/Interface';
import { promptAction } from '@kit.ArkUI';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;
let transliterator = i18n.Transliterator.getInstance('Any-Latn');
let options: intl.CollatorOptions = {
  localeMatcher: "lookup",
  usage: "sort",
  sensitivity: "variant",
  numeric: true
};
let locale = new intl.Locale();
let collator = new intl.Collator(locale.toString(), options);
let intervalId = -1

function clearArtists(array: Artist[]): Artist[] {
  const uniqueItems = new Map<string, Artist>();
  array.forEach(item => uniqueItems.set(item.id, item));
  return Array.from(uniqueItems.values());
}

function claerSongs(array: Song[]): Song[] {
  const uniqueItems = new Map<string, Song>();
  array.forEach(item => uniqueItems.set(item.id, item));
  return Array.from(uniqueItems.values());
}

function clearAlbums(array: Album[]): Album[] {
  const uniqueItems = new Map<string, Album>();
  array.forEach(item => uniqueItems.set(item.id, item));
  return Array.from(uniqueItems.values());
}

async function syncFromServer(baseURL: string, username: string, password: string, artists: Artist[], albums: Album[],
  songs: Song[], playlists: Playlist[], starredSongs: Song[]) {
  let status: string | null = await ping(baseURL, username, password)
  console.log("Server status", status)
  if (status === 'ok') {
    console.log("开始同步服务器");
    let remote_artists: Artist[] = []
    let remote_albums: Album[] = []
    let remote_songs: Song[] = []
    let remote_playlists: Playlist[] = []
    let remote_starredSongs: Song[] = []
    remote_artists = await getIndexes(baseURL, username, password)
    remote_artists = clearArtists(remote_artists)
    for (const artist of remote_artists) {
      artist.biography = await getArtistInfo(baseURL, username, password, artist.id)
      artist.album = await getArtist(baseURL, username, password, artist.id);
      remote_albums = remote_albums.concat(artist.album!);
      remote_albums = clearAlbums(remote_albums)
      for (const album of artist.album!) {
        album.song = await getAlbum(baseURL, username, password, album.id);
        remote_songs = remote_songs.concat(album.song!);
        remote_songs = claerSongs(remote_songs)
      }
    }
    remote_playlists = (await getPlaylists(baseURL, username, password)).sort((a, b) => {
      return Date.parse(b.changed) - Date.parse(a.changed);
    })
    let starred = await getStarred(baseURL, username, password)
    if (starred !== null) {
      remote_starredSongs = starred!.song!
    }
    remote_songs.sort((a, b) => {
      return collator.compare(transliterator.transform(a.title), transliterator.transform(b.title));
    })
    remote_albums.sort((a, b) => {
      return collator.compare(transliterator.transform(a.title), transliterator.transform(b.title));
    })
    remote_artists.sort((a, b) => {
      return collator.compare(transliterator.transform(a.name), transliterator.transform(b.name));
    })
    console.log("获取到数据");
    if (JSON.stringify(remote_artists) !== JSON.stringify(artists) ||
      JSON.stringify(remote_albums) !== JSON.stringify(albums) ||
      JSON.stringify(remote_songs) !== JSON.stringify(songs) ||
      JSON.stringify(remote_playlists) !== JSON.stringify(playlists) ||
      JSON.stringify(remote_starredSongs) !== JSON.stringify(starredSongs)) {
      artists = remote_artists;
      albums = remote_albums;
      songs = remote_songs;
      playlists = remote_playlists;
      starredSongs = remote_starredSongs;
      try {
        workerPort.postMessage({
          type: "update",
          artists: JSON.stringify(artists),
          albums: JSON.stringify(albums),
          songs: JSON.stringify(songs),
          playlists: JSON.stringify(playlists),
          starredSongs: JSON.stringify(starredSongs),
        });
      } catch (e) {
        console.error('postMessage failed:', e);
      }
    } else {
      workerPort.postMessage({ type: "unchanged" });
    }
  } else {
    workerPort.postMessage({ type: "faild" });
    console.log("连接服务器失败")
    promptAction.showToast({
      message: '连接服务器失败，请检查网络！',
      duration: 500
    });
  }
}

/**
 * Defines the event handler to be called when the worker thread receives a message sent by the host thread.
 * The event handler is executed in the worker thread.
 *
 * @param event message data
 */
workerPort.onmessage = async (event: MessageEvents) => {
  if (event.data.type.toString() === "start") {
    console.log("同步任务启动")
    let baseURL: string = event.data.baseURL.toString();
    let username: string = event.data.username.toString();
    let password: string = event.data.password.toString();
    let artists: Artist[] = JSON.parse(event.data.artists);
    let albums: Album[] = JSON.parse(event.data.albums);
    let songs: Song[] = JSON.parse(event.data.songs);
    let playlists: Playlist[] = JSON.parse(event.data.playlists);
    let starredSongs: Song[] = JSON.parse(event.data.starredSongs);
    await syncFromServer(baseURL, username, password, artists, albums, songs, playlists, starredSongs)
    intervalId = setInterval(async () => {
      await syncFromServer(baseURL, username, password, artists, albums, songs, playlists, starredSongs)
    }, 30 * 1000);
  } else if (event.data.type.toString() === "stop") {
    clearInterval(intervalId)
    console.log("同步任务停止")
  }
};

/**
 * Defines the event handler to be called when the worker receives a message that cannot be deserialized.
 * The event handler is executed in the worker thread.
 *
 * @param event message data
 */
workerPort.onmessageerror = (event: MessageEvents) => {
};

/**
 * Defines the event handler to be called when an exception occurs during worker execution.
 * The event handler is executed in the worker thread.
 *
 * @param event error message
 */
workerPort.onerror = (event: ErrorEvent) => {
};
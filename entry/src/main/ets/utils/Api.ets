import axios, { AxiosResponse } from '@ohos/axios'
import { ApiResponse, Artist, LyricsList, Playlist, SubsonicResponse } from './Interface'

axios.defaults.headers.post['Content-Type'] = 'application/json'

export async function ping(baseURL: string, auth: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<ApiResponse>>(baseURL + '/rest/ping' + auth, {}, {
        timeout: 1000,
        readTimeout: 1000,
        connectTimeout: 1000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.status
  } catch (error) {
    console.error(JSON.stringify(error));
    return undefined
  }
}

export async function getMusicFolders(baseURL: string, auth: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<ApiResponse>>(baseURL + '/rest/getMusicFolders' + auth, {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.musicFolders!.musicFolder!
  } catch (error) {
    console.error(JSON.stringify(error));
    return []
  }
}

export async function getIndexes(baseURL: string, auth: string, musicFolderId: string) {
  let artists: Artist[] = []
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<ApiResponse>>(baseURL + '/rest/getIndexes' + auth +
        (musicFolderId !== '' ? `&musicFolderId=${musicFolderId}` : ""), {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    subsonicResponse.indexes!.index.forEach(item => {
      artists = artists.concat(item.artist)
    })
    return artists
  } catch (error) {
    console.error(JSON.stringify(error));
    return []
  }
}

export async function getArtists(baseURL: string, auth: string, musicFolderId: string) {
  let artists: Artist[] = []
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<ApiResponse>>(baseURL + '/rest/getArtists' + auth +
        (musicFolderId !== '' ? `&musicFolderId=${musicFolderId}` : ""), {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    subsonicResponse.artists!.index.forEach(item => {
      artists = artists.concat(item.artist)
    })
    return artists
  } catch (error) {
    console.error(JSON.stringify(error));
    return []
  }
}

export async function getGenres(baseURL: string, auth: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getGenres' + auth, {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    console.log(JSON.stringify(subsonicResponse.genres))
  } catch (error) {
    console.error(JSON.stringify(error));
  }
}

export async function getArtist(baseURL: string, auth: string, id: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getArtist' + auth + `&id=${id}`, {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.artist
  } catch (error) {
    console.error(JSON.stringify(error));
    return undefined
  }
}

export async function getArtistInfo(baseURL: string, auth: string, id: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getArtistInfo' + auth + `&id=${id}`, {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    if (subsonicResponse.artistInfo!.biography !== undefined && subsonicResponse.artistInfo!.biography.length > 0) {
      return '\u3000\u3000' + subsonicResponse.artistInfo!.biography
    } else {
      return '暂无介绍'
    }
  } catch (error) {
    console.error(JSON.stringify(error));
    return '暂无介绍'
  }
}

export async function getAlbumSong(baseURL: string, auth: string, id: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getAlbum' + auth + `&id=${id}`, {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.album!.song
  } catch (error) {
    console.error(JSON.stringify(error));
    return []
  }
}

export async function getAlbum(baseURL: string, auth: string, id: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getAlbum' + auth + `&id=${id}`, {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.album
  } catch (error) {
    console.error(JSON.stringify(error));
    return undefined
  }
}

export async function getAlbumList(baseURL: string, auth: string, offset: number, musicFolderId: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getAlbumList2' + auth +
        `&type=alphabeticalByName&size=500&offset=${offset}` +
        (musicFolderId !== '' ? `&musicFolderId=${musicFolderId}` : ""), {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.albumList2!.album
  } catch (error) {
    console.error(JSON.stringify(error));
    return undefined
  }
}

export async function getAlbumListByArtist(baseURL: string, auth: string, offset: number, musicFolderId: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getAlbumList2' + auth +
        `&type=alphabeticalByArtist&size=500&offset=${offset}` +
        (musicFolderId !== '' ? `&musicFolderId=${musicFolderId}` : ""), {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.albumList2!.album
  } catch (error) {
    console.error(JSON.stringify(error));
    return undefined
  }
}

export async function getRecentAlbums(baseURL: string, auth: string, musicFolderId: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getAlbumList2' + auth + `&type=recent` +
        (musicFolderId !== '' ? `&musicFolderId=${musicFolderId}` : ""), {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    if (subsonicResponse.albumList2!.album) {
      return subsonicResponse.albumList2!.album
    }
    return []
  } catch (error) {
    console.error(JSON.stringify(error));
    return []
  }
}

export async function getNewestAlbums(baseURL: string, auth: string, musicFolderId: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getAlbumList2' + auth + `&type=newest` +
        (musicFolderId !== '' ? `&musicFolderId=${musicFolderId}` : ""), {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    if (subsonicResponse.albumList2!.album) {
      return subsonicResponse.albumList2!.album
    }
    return []
  } catch (error) {
    console.error(JSON.stringify(error));
    return []
  }
}

export async function getFrequentAlbums(baseURL: string, auth: string, musicFolderId: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getAlbumList2' + auth + `&type=frequent` +
        (musicFolderId !== '' ? `&musicFolderId=${musicFolderId}` : ""), {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    if (subsonicResponse.albumList2!.album) {
      return subsonicResponse.albumList2!.album
    }
    return []
  } catch (error) {
    console.error(JSON.stringify(error));
    return []
  }
}

export async function getRandomAlbums(baseURL: string, auth: string, musicFolderId: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getAlbumList2' + auth + `&type=random` +
        (musicFolderId !== '' ? `&musicFolderId=${musicFolderId}` : ""), {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    if (subsonicResponse.albumList2!.album) {
      return subsonicResponse.albumList2!.album
    }
    return []
  } catch (error) {
    console.error(JSON.stringify(error));
    return []
  }
}

export async function getSong(baseURL: string, auth: string, id: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getSong' + auth + `&id=${id}`, {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.song
  } catch (error) {
    console.error(JSON.stringify(error));
    return undefined
  }
}

export async function getPlaylists(baseURL: string, auth: string) {
  let playlists: Playlist[] = []
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<ApiResponse>>(baseURL + '/rest/getPlaylists' + auth, {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    if (subsonicResponse.playlists!.playlist && subsonicResponse.playlists!.playlist.length > 0) {
      await Promise.all(subsonicResponse.playlists!.playlist.map(async (playlist) => {
        let tmpPlaylist = await getPlaylist(baseURL, auth, playlist.id)
        if (tmpPlaylist !== undefined) {
          playlists.push(tmpPlaylist)
        }
      }));
    }
    return playlists
  } catch (error) {
    console.error(JSON.stringify(error));
    return []
  }
}

export async function getPlaylist(baseURL: string, auth: string, id: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<ApiResponse>>(baseURL + '/rest/getPlaylist' + auth + `&id=${id}`, {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      });
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"];
    return subsonicResponse.playlist!
  } catch (error) {
    console.error(JSON.stringify(error));
    return undefined
  }
}

export async function getLyrics(baseURL: string, auth: string, id: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getLyricsBySongId' + auth + `&id=${id}`, {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    let lyricsList: LyricsList = subsonicResponse.lyricsList!
    if (lyricsList.structuredLyrics !== undefined) {
      return lyricsList.structuredLyrics[0]
    }
    return undefined
  } catch (error) {
    console.error(JSON.stringify(error));
    return undefined
  }
}

export async function getCover(baseURL: string, auth: string, id: string, size: number) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getCoverArt' + auth + `&id=${id}&size=${size}`, {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    return response.data
  } catch (error) {
    console.error(JSON.stringify(error));
    return undefined
  }
}

export async function updatePlaylist(baseURL: string, auth: string, playlistId: string, name?: string, comment?: string, songIdToAdd?: string, songIndexToRemove?: number) {
  let url = baseURL + '/rest/updatePlaylist' + auth + `&playlistId=${playlistId}`
  if (name !== undefined) {
    url += `&name=${name}`
  }
  if (comment !== undefined && comment.length > 0) {
    url += `&comment=${comment}`
  } else {
    url += `&comment=`
  }
  if (songIdToAdd !== undefined) {
    url += `&songIdToAdd=${songIdToAdd}`
  }
  if (songIndexToRemove !== undefined) {
    url += `&songIndexToRemove=${songIndexToRemove}`
  }
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(url, {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    return true
  } catch (error) {
    console.error(JSON.stringify(error));
    return false
  }
}

export async function createPlaylist(baseURL: string, auth: string, name: string, comment: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/createPlaylist' + auth + `&name=${name}`, {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    let playlist = subsonicResponse.playlist
    if (playlist !== undefined) {
      let success = await updatePlaylist(baseURL, auth, playlist.id, undefined, comment)
      if (success === false) {
        return false
      }
    } else {
      return false
    }
    return true
  } catch (error) {
    console.error(JSON.stringify(error));
    return false
  }
}

export async function deletePlaylist(baseURL: string, auth: string, id: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/deletePlaylist' + auth + `&id=${id}`, {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    return true
  } catch (error) {
    console.error(JSON.stringify(error));
    return false
  }
}

export async function getStarredArtists(baseURL: string, auth: string, musicFolderId: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getStarred2' + auth +
        (musicFolderId !== '' ? `&musicFolderId=${musicFolderId}` : ""), {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    if (Object.keys(subsonicResponse.starred2!).length !== 0 && subsonicResponse.starred2!.artist !== undefined) {
      return subsonicResponse.starred2!.artist
    }
    return []
  } catch (error) {
    console.error(JSON.stringify(error));
    return []
  }
}

export async function getStarredAlbums(baseURL: string, auth: string, musicFolderId: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getStarred2' + auth +
        (musicFolderId !== '' ? `&musicFolderId=${musicFolderId}` : ""), {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    if (Object.keys(subsonicResponse.starred2!).length !== 0 && subsonicResponse.starred2!.album !== undefined) {
      return subsonicResponse.starred2!.album
    }
    return []
  } catch (error) {
    console.error(JSON.stringify(error));
    return []
  }
}

export async function star(baseURL: string, auth: string, id: string, type?: string) {
  let idType = "id"
  if (type !== undefined) {
    idType = type === "album" ? "albumId" : "artistId"
  }
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/star' + auth + `&${idType}=${id}`, {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    return true
  } catch (error) {
    console.error(JSON.stringify(error));
    return false
  }
}

export async function unstar(baseURL: string, auth: string, id: string, type?: string) {
  let idType = "id"
  if (type !== undefined) {
    idType = type === "album" ? "albumId" : "artistId"
  }
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/unstar' + auth + `&${idType}=${id}`, {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    return true
  } catch (error) {
    console.error(JSON.stringify(error));
    return false
  }
}

export async function createShare(baseURL: string, auth: string, id: string) {
  let currentDate = new Date();
  currentDate.setMonth(currentDate.getMonth() + 1);
  let time = currentDate.getTime();
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/createShare' + auth +
        `&id=${id}&expires=${time}`, {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    if (subsonicResponse.shares !== undefined) {
      return subsonicResponse.shares.share[0].url
    }
    return undefined
  } catch (error) {
    console.error(JSON.stringify(error));
    return undefined
  }
}

export async function search(baseURL: string, auth: string, query: string, musicFolderId: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/search2' + auth + `&query=${query}&songCount=500&albumCount=500&artistCount=500` +
        (musicFolderId !== '' ? `&musicFolderId=${musicFolderId}` : ""), {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.searchResult2;
  } catch (error) {
    console.error(JSON.stringify(error));
    return undefined;
  }
}

export async function searchSongs(baseURL: string, auth: string, query: string, songOffset:number, musicFolderId: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/search2' + auth + `&query=${query}&songOffset=${songOffset}&songCount=500&albumCount=0&artistCount=0` +
        (musicFolderId !== '' ? `&musicFolderId=${musicFolderId}` : ""), {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.searchResult2?.song;
  } catch (error) {
    console.error(JSON.stringify(error));
    return undefined;
  }
}

export async function searchAlbums(baseURL: string, auth: string, query: string, albumOffset:number, musicFolderId: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/search2' + auth + `&query=${query}&songCount=0&albumOffset=${albumOffset}&albumCount=500&artistCount=0` +
        (musicFolderId !== '' ? `&musicFolderId=${musicFolderId}` : ""), {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.searchResult2?.album;
  } catch (error) {
    console.error(JSON.stringify(error));
    return undefined;
  }
}

export async function searchArtists(baseURL: string, auth: string, query: string, artistOffset:number, musicFolderId: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/search2' + auth + `&query=${query}&songCount=0&albumCount=0&artistOffset=${artistOffset}&artistCount=500` +
        (musicFolderId !== '' ? `&musicFolderId=${musicFolderId}` : ""), {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.searchResult2?.artist;
  } catch (error) {
    console.error(JSON.stringify(error));
    return undefined;
  }
}

export async function getAllSongs(baseURL: string, auth: string, songOffset: number, musicFolderId: string) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/search2' + auth + `&artistCount=0&albumCount=0&songCount=500&songOffset=${songOffset}` +
        (musicFolderId !== '' ? `&musicFolderId=${musicFolderId}` : "") + '&query=', {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.searchResult2!.song;
  } catch (error) {
    console.error(JSON.stringify(error));
    return undefined;
  }
}

export async function scrobble(baseURL: string, auth: string, id: string, submission: boolean) {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/scrobble' + auth +
        `&id=${id}&submission=${submission}`, {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    return true
  } catch (error) {
    console.error(JSON.stringify(error));
    return false
  }
}

export async function getVerse() {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>("https://v1.hitokoto.cn/?c=i&encode=json&max_length=12", {}, {
        timeout: 10000,
        readTimeout: 10000,
        connectTimeout: 10000
      })
    if (response.status === 200) {
      return response.data
    }
    return undefined
  } catch (error) {
    console.error(JSON.stringify(error));
    return undefined
  }
}
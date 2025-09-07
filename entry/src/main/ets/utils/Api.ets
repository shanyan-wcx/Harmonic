import axios, { AxiosResponse } from '@ohos/axios'
import CryptoJS from '@ohos/crypto-js'
import { ApiResponse, Artist, LyricsList, Playlist, SubsonicResponse, SearchOption } from './Interface'

axios.defaults.headers.post['Content-Type'] = 'application/json'

let salt = 'abcdef'
let version = '1.16.1'
let client = 'Harmonic'

export async function ping(baseURL: string, username: string, password: string) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<ApiResponse>>(baseURL + '/rest/ping' + auth, {
        readTimeout: 100,
        timeout: 100
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.status
  } catch (error) {
    console.error(JSON.stringify(error));
    return undefined
  }
}

export async function getMusicFolders(baseURL: string, username: string, password: string) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<ApiResponse>>(baseURL + '/rest/getMusicFolders' + auth, {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.musicFolders!.musicFolder!
  } catch (error) {
    console.error(JSON.stringify(error));
    return []
  }
}

export async function getIndexes(baseURL: string, username: string, password: string, musicFolderId: number) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  let artists: Artist[] = []
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<ApiResponse>>(baseURL + '/rest/getIndexes' + auth +
        (musicFolderId !== -1 ? `&musicFolderId=${musicFolderId}` : ""), {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    subsonicResponse.indexes!.index.forEach(item => {
      artists = artists.concat(item.artist)
    })
    return artists
  } catch (error) {
    console.error(`/==getIndexes/ error: ${JSON.stringify(error)}`);
    return []
  }
}

export async function getGenres(baseURL: string, username: string, password: string) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getGenres' + auth, {
        timeout: 10000
      })
    console.log(JSON.stringify(response.data))
  } catch (error) {
    console.error(JSON.stringify(error));
  }
}

export async function getArtist(baseURL: string, username: string, password: string, id: string) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getArtist' + auth + `&id=${id}`, {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.artist
  } catch (error) {
    console.error(JSON.stringify(error));
    return undefined
  }
}

// export async function getArtistAlbum(baseURL: string, username: string, password: string, id: string) {
//   let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
//   try {
//     const response: AxiosResponse =
//       await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getArtist' + auth + `&id=${id}`, {
//         timeout: 10000
//       })
//     const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
//     return subsonicResponse.artist!.album ?? []
//   } catch (error) {
//     console.error(JSON.stringify(error));
//     return []
//   }
// }

export async function getArtistInfo(baseURL: string, username: string, password: string, id: string) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getArtistInfo' + auth + `&id=${id}`, {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    if (subsonicResponse.artistInfo!.biography !== undefined) {
      return '\u3000\u3000' + subsonicResponse.artistInfo!.biography
    } else {
      return '暂无介绍'
    }
  } catch (error) {
    console.error(JSON.stringify(error));
    return '暂无介绍'
  }
}

export async function getAlbumSong(baseURL: string, username: string, password: string, id: string) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getAlbum' + auth + `&id=${id}`, {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.album!.song
  } catch (error) {
    console.error(`getAlbumSong error: ${JSON.stringify(error)}`);
    return []
  }
}

export async function getAlbum(baseURL: string, username: string, password: string, id: string) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getAlbum' + auth + `&id=${id}`, {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.album
  } catch (error) {
    console.error(`/==getAlbum/ error: ${JSON.stringify(error)}`);
    return undefined
  }
}

export async function getAlbumList(
  baseURL: string,
  username: string,
  password: string,
  offset: number,
  musicFolderId: number,
  size=500,
) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getAlbumList' + auth +
        `&type=alphabeticalByName&size=${size}&offset=${offset}` +
        (musicFolderId !== -1 ? `&musicFolderId=${musicFolderId}` : ""), {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.albumList!.album
  } catch (error) {
    console.error(`/==getAlbumList/, error: ${JSON.stringify(error)}`);
    return undefined
  }
}

export async function getRecentAlbums(baseURL: string, username: string, password: string, musicFolderId: number) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getAlbumList' + auth + `&type=recent` +
        (musicFolderId !== -1 ? `&musicFolderId=${musicFolderId}` : ""), {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    if (subsonicResponse.albumList!.album) {
      return subsonicResponse.albumList!.album
    }
    return []
  } catch (error) {
    console.error(`/==getRecentAlbums/ error: ${JSON.stringify(error)}`);
    return []
  }
}

export async function getNewestAlbums(baseURL: string, username: string, password: string, musicFolderId: number) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getAlbumList' + auth + `&type=newest` +
        (musicFolderId !== -1 ? `&musicFolderId=${musicFolderId}` : ""), {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    if (subsonicResponse.albumList!.album) {
      return subsonicResponse.albumList!.album
    }
    return []
  } catch (error) {
    console.error(`/==getNewestAlbums/ error: ${JSON.stringify(error)}`);
    return []
  }
}

export async function getFrequentAlbums(baseURL: string, username: string, password: string, musicFolderId: number) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getAlbumList' + auth + `&type=frequent` +
        (musicFolderId !== -1 ? `&musicFolderId=${musicFolderId}` : ""), {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    if (subsonicResponse.albumList!.album) {
      return subsonicResponse.albumList!.album
    }
    return []
  } catch (error) {
    console.error(`/==getFrequentAlbums/ error: ${JSON.stringify(error)}`);
    return []
  }
}

export async function getRandomAlbums(baseURL: string, username: string, password: string, musicFolderId: number) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getAlbumList' + auth + `&type=random` +
        (musicFolderId !== -1 ? `&musicFolderId=${musicFolderId}` : ""), {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    if (subsonicResponse.albumList!.album) {
      return subsonicResponse.albumList!.album
    }
    return []
  } catch (error) {
    console.error(`/==getRandomAlbums/ error: ${JSON.stringify(error)}`);
    return []
  }
}

export async function getSong(baseURL: string, username: string, password: string, id: string) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getSong' + auth + `&id=${id}`, {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.song
  } catch (error) {
    console.error(`/==getSong/ error: ${JSON.stringify(error)}`);
    return undefined
  }
}

export async function getPlaylists(baseURL: string, username: string, password: string) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  let playlists: Playlist[] = []
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<ApiResponse>>(baseURL + '/rest/getPlaylists' + auth, {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    if (subsonicResponse.playlists!.playlist && subsonicResponse.playlists!.playlist.length > 0) {
      await Promise.all(subsonicResponse.playlists!.playlist.map(async (playlist) => {
        let tmpPlaylist = await getPlaylist(baseURL, username, password, playlist.id)
        if (tmpPlaylist !== undefined) {
          playlists.push(tmpPlaylist)
        }
      }));
    }
    return playlists
  } catch (error) {
    console.error(`/==getPlaylists/ error: ${JSON.stringify(error)}`);
    return []
  }
}

export async function getPlaylist(baseURL: string, username: string, password: string, id: string) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<ApiResponse>>(baseURL + '/rest/getPlaylist' + auth + `&id=${id}`, {
        timeout: 10000
      });
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"];
    return subsonicResponse.playlist!
  } catch (error) {
    console.error(`/==getPlaylist/ error: ${JSON.stringify(error)}`);
    return undefined
  }
}

export async function getLyrics(baseURL: string, username: string, password: string, id: string) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getLyricsBySongId' + auth + `&id=${id}`, {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    let lyricsList: LyricsList = subsonicResponse.lyricsList!
    if (lyricsList.structuredLyrics !== undefined) {
      return lyricsList.structuredLyrics[0]
    }
    return undefined
  } catch (error) {
    console.error(`/==getLyrics/ error: ${JSON.stringify(error)}`);
    return undefined
  }
}

export async function getCover(baseURL: string, username: string, password: string, id: string, size: number) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getCoverArt' + auth + `&id=${id}&size=${size}`, {
        timeout: 10000
      })
    return response.data
  } catch (error) {
    console.error(`/==getCover/ error: ${JSON.stringify(error)}`);
    return undefined
  }
}

export async function updatePlaylist(baseURL: string, username: string, password: string, playlistId: string,
  name?: string, comment?: string, songIdToAdd?: string,
  songIndexToRemove?: number) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
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
      await axios.post<string, AxiosResponse<string>>(url, {
        timeout: 10000
      })
    return true
  } catch (error) {
    console.error(JSON.stringify(error));
    return false
  }
}

export async function createPlaylist(baseURL: string, username: string, password: string, name: string,
  comment: string) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/createPlaylist' + auth + `&name=${name}`, {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    let playlist = subsonicResponse.playlist
    if (playlist !== undefined) {
      let success = await updatePlaylist(baseURL, username, password, playlist.id, undefined, comment)
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

export async function deletePlaylist(baseURL: string, username: string, password: string, id: string) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/deletePlaylist' + auth + `&id=${id}`, {
        timeout: 10000
      })
    return true
  } catch (error) {
    console.error(JSON.stringify(error));
    return false
  }
}

export async function getStarredArtists(baseURL: string, username: string, password: string, musicFolderId: number) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getStarred' + auth +
        (musicFolderId !== -1 ? `&musicFolderId=${musicFolderId}` : ""), {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    if (Object.keys(subsonicResponse.starred!).length !== 0 && subsonicResponse.starred!.artist !== undefined) {
      return subsonicResponse.starred!.artist
    }
    return []
  } catch (error) {
    console.error(JSON.stringify(error));
    return []
  }
}

export async function getStarredAlbums(baseURL: string, username: string, password: string, musicFolderId: number) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getStarred' + auth +
        (musicFolderId !== -1 ? `&musicFolderId=${musicFolderId}` : ""), {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    if (Object.keys(subsonicResponse.starred!).length !== 0 && subsonicResponse.starred!.album !== undefined) {
      return subsonicResponse.starred!.album
    }
    return []
  } catch (error) {
    console.error(JSON.stringify(error));
    return []
  }
}

export async function star(baseURL: string, username: string, password: string, id: string, type?: string) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  let idType = "id"
  if (type !== undefined) {
    idType = type === "album" ? "albumId" : "artistId"
  }
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/star' + auth + `&${idType}=${id}`, {
        timeout: 10000
      })
    return true
  } catch (error) {
    console.error(JSON.stringify(error));
    return false
  }
}

export async function unstar(baseURL: string, username: string, password: string, id: string, type?: string) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  let idType = "id"
  if (type !== undefined) {
    idType = type === "album" ? "albumId" : "artistId"
  }
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/unstar' + auth + `&${idType}=${id}`, {
        timeout: 10000
      })
    return true
  } catch (error) {
    console.error(JSON.stringify(error));
    return false
  }
}

export async function createShare(baseURL: string, username: string, password: string, id: string) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  let currentDate = new Date();
  currentDate.setMonth(currentDate.getMonth() + 1);
  let time = currentDate.getTime();
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/createShare' + auth +
        `&id=${id}&expires=${time}`, {
        timeout: 10000
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

export async function search(
  baseURL: string,
  username: string,
  password: string,
  query: string,
  musicFolderId: number,
  options?: SearchOption,
) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  let artistCount: number = options?.artistCount ?? 20;
  let artistOffset: number = options?.artistOffset ?? 0;
  let albumCount: number = options?.albumCount ?? 20;
  let albumOffset: number = options?.artistOffset ?? 0;
  let songCount: number = options?.songCount ?? 20;
  let songOffset: number = options?.songOffset ?? 0;
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/search2' + auth + `&query=${query}`
        + `&artistCount=${artistCount}` + `&artistOffset=${artistOffset}`
        + `&albumCount=${albumCount}` + `&albumOffset=${albumOffset}`
        + `&songCount=${songCount}` + `&songOffset=${songOffset}` +
        (musicFolderId !== -1 ? `&musicFolderId=${musicFolderId}` : ""), {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.searchResult2;
  } catch (error) {
    console.error(`/==search/ error: ${JSON.stringify(error)}`);
    return undefined;
  }
}

export async function scrobble(baseURL: string, username: string, password: string, id: string, submission: boolean) {
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/scrobble' + auth +
        `&id=${id}&submission=${submission}`, {
        timeout: 10000
      })
    return true
  } catch (error) {
    console.error(`/==scrobble/ error: ${JSON.stringify(error)}`);
    return false
  }
}

export async function getVerse() {
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>("https://v1.hitokoto.cn/?c=i&encode=json&max_length=12")
    if (response.status === 200) {
      return response.data
    }
    return undefined
  } catch (error) {
    console.error(`/==getVerse/ error: ${JSON.stringify(error)}`);
    return undefined
  }
}
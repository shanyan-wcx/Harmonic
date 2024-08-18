import axios, { AxiosResponse } from '@ohos/axios'
import CryptoJS from '@ohos/crypto-js'
import { ApiResponse, Artist, LyricsList, Playlist, SubsonicResponse } from './Interface'
import { promptAction } from '@kit.ArkUI'

axios.defaults.headers.post['Content-Type'] = 'application/json'

let salt = 'abcdef'
let version = '1.16.1'
let client = 'Harmonic'

export async function ping() {
  let baseURL = AppStorage.get('baseURL')!
  let username = AppStorage.get('username')!
  let password = AppStorage.get('password')!
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
    return null
  }
}

export async function getIndexes() {
  let baseURL = AppStorage.get('baseURL')!
  let username = AppStorage.get('username')!
  let password = AppStorage.get('password')!
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  let artists: Artist[] = []
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<ApiResponse>>(baseURL + '/rest/getIndexes' + auth + `&id=0`, {
        timeout: 10000
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

export async function getGenres() {
  let baseURL = AppStorage.get('baseURL')!
  let username = AppStorage.get('username')!
  let password = AppStorage.get('password')!
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

export async function getArtist(id: string) {
  let baseURL = AppStorage.get('baseURL')!
  let username = AppStorage.get('username')!
  let password = AppStorage.get('password')!
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getArtist' + auth + `&id=${id}`, {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.artist!.album
  } catch (error) {
    console.error(JSON.stringify(error));
    return []
  }
}

export async function getArtistInfo(id: string) {
  let baseURL = AppStorage.get('baseURL')!
  let username = AppStorage.get('username')!
  let password = AppStorage.get('password')!
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

export async function getAlbum(id: string) {
  let baseURL = AppStorage.get('baseURL')!
  let username = AppStorage.get('username')!
  let password = AppStorage.get('password')!
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getAlbum' + auth + `&id=${id}`, {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    return subsonicResponse.album!.song
  } catch (error) {
    console.error(JSON.stringify(error));
    return []
  }
}

export async function getSong(id: string) {
  let baseURL = AppStorage.get('baseURL')!
  let username = AppStorage.get('username')!
  let password = AppStorage.get('password')!
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getSong' + auth + `&id=${id}`, {
        timeout: 10000
      })
    console.log(JSON.stringify(response.data))
  } catch (error) {
    console.error(JSON.stringify(error));
  }
}

export async function getPlaylists() {
  let baseURL = AppStorage.get('baseURL')!
  let username = AppStorage.get('username')!
  let password = AppStorage.get('password')!
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
        let tmpPlaylist = await getPlaylist(playlist.id)
        if (tmpPlaylist !== null) {
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

export async function getPlaylist(id: string) {
  let baseURL = AppStorage.get('baseURL')!
  let username = AppStorage.get('username')!
  let password = AppStorage.get('password')!
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<ApiResponse>>(baseURL + '/rest/getPlaylist' + auth + `&id=${id}`, {
        timeout: 10000
      });
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"];
    return subsonicResponse.playlist!
  } catch (error) {
    console.error(JSON.stringify(error));
    return null
  }
}

export async function getLyrics(id: string) {
  let baseURL = AppStorage.get('baseURL')!
  let username = AppStorage.get('username')!
  let password = AppStorage.get('password')!
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
    return null
  } catch (error) {
    console.error(JSON.stringify(error));
    return null
  }
}

export async function getCover(id: string) {
  let baseURL = AppStorage.get('baseURL')!
  let username = AppStorage.get('username')!
  let password = AppStorage.get('password')!
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getCoverArt' + auth + `&id=${id}&size=512`, {
        timeout: 10000
      })
    return response.data
  } catch (error) {
    console.error(JSON.stringify(error));
    return null
  }
}

export async function updatePlaylist(playlistId: string, name?: string, comment?: string, songIdToAdd?: string,
  songIndexToRemove?: number) {
  let baseURL = AppStorage.get('baseURL')!
  let username = AppStorage.get('username')!
  let password = AppStorage.get('password')!
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  let url = baseURL + '/rest/updatePlaylist' + auth + `&playlistId=${playlistId}`
  if (name !== undefined) {
    url += `&name=${name}`
  }
  if (comment !== undefined) {
    url += `&comment=${comment}`
  }
  if (songIdToAdd !== undefined) {
    url += `&songIdToAdd=${songIdToAdd}`
  }
  if (songIndexToRemove !== undefined) {
    url += `&songIndexToRemove=${songIndexToRemove}`
  }
  console.log(url)
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(url, {
        timeout: 10000
      })
    console.log(JSON.stringify(response.data))
    return true
  } catch (error) {
    console.error(JSON.stringify(error));
    return false
  }
}

export async function getStarred() {
  let baseURL = AppStorage.get('baseURL')!
  let username = AppStorage.get('username')!
  let password = AppStorage.get('password')!
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/getStarred' + auth, {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    if (Object.keys(subsonicResponse.starred!).length !== 0 && subsonicResponse.starred!.song !== undefined) {
      return subsonicResponse.starred
    }
    return null
  } catch (error) {
    console.error(JSON.stringify(error));
    return null
  }
}

export async function star(id: string) {
  let baseURL = AppStorage.get('baseURL')!
  let username = AppStorage.get('username')!
  let password = AppStorage.get('password')!
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/star' + auth + `&id=${id}`, {
        timeout: 10000
      })
    promptAction.showToast({
      message: '收藏成功！',
      duration: 500
    });
    return true
  } catch (error) {
    console.error(JSON.stringify(error));
    promptAction.showToast({
      message: '收藏失败，请检查网络！',
      duration: 500
    });
    return false
  }
}

export async function unstar(id: string) {
  let baseURL = AppStorage.get('baseURL')!
  let username = AppStorage.get('username')!
  let password = AppStorage.get('password')!
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/rest/unstar' + auth + `&id=${id}`, {
        timeout: 10000
      })
    promptAction.showToast({
      message: '取消收藏成功！',
      duration: 500
    });
    return true
  } catch (error) {
    console.error(JSON.stringify(error));
    promptAction.showToast({
      message: '取消收藏失败，请检查网络！',
      duration: 500
    });
    return false
  }
}
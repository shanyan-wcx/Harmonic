import axios, { AxiosResponse } from '@ohos/axios'
import CryptoJS from '@ohos/crypto-js'
import { ApiResponse, Artist, LyricsList, Playlist, SubsonicResponse } from './Interface'

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
    const response: AxiosResponse = await axios.post<string, AxiosResponse<ApiResponse>>(baseURL + '/ping' + auth, {
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
      await axios.post<string, AxiosResponse<ApiResponse>>(baseURL + '/getIndexes' + auth + `&id=0`, {
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
    const response: AxiosResponse = await axios.post<string, AxiosResponse<string>>(baseURL + '/getGenres' + auth, {
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
      await axios.post<string, AxiosResponse<string>>(baseURL + '/getArtist' + auth + `&id=${id}`, {
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
      await axios.post<string, AxiosResponse<string>>(baseURL + '/getArtistInfo' + auth + `&id=${id}`, {
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
      await axios.post<string, AxiosResponse<string>>(baseURL + '/getAlbum' + auth + `&id=${id}`, {
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
      await axios.post<string, AxiosResponse<string>>(baseURL + '/getSong' + auth + `&id=${id}`, {
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
      await axios.post<string, AxiosResponse<ApiResponse>>(baseURL + '/getPlaylists' + auth, {
        timeout: 10000
      })
    const subsonicResponse: SubsonicResponse = response.data["subsonic-response"]
    if (subsonicResponse.playlists!.playlist && subsonicResponse.playlists!.playlist.length > 0) {
      await Promise.all(subsonicResponse.playlists!.playlist.map(async (playlist) => {
        const response: AxiosResponse =
          await axios.post<string, AxiosResponse<ApiResponse>>(baseURL + '/getPlaylist' + auth + `&id=${playlist.id}`, {
            timeout: 10000
          });
        const subsonicResponse: SubsonicResponse = response.data["subsonic-response"];
        playlists.push(subsonicResponse.playlist!);
      }));
    }
    return playlists
  } catch (error) {
    console.error(JSON.stringify(error));
    return []
  }
}

export async function getLyrics(id: string) {
  let baseURL = AppStorage.get('baseURL')!
  let username = AppStorage.get('username')!
  let password = AppStorage.get('password')!
  let auth = `?u=${username}&t=${CryptoJS.MD5(password + salt)}&s=${salt}&v=${version}&c=${client}&f=json`
  try {
    const response: AxiosResponse =
      await axios.post<string, AxiosResponse<string>>(baseURL + '/getLyricsBySongId' + auth + `&id=${id}`, {
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
      await axios.post<string, AxiosResponse<string>>(baseURL + '/getCoverArt' + auth + `&id=${id}&size=512`, {
        timeout: 10000
      })
    return response.data
  } catch (error) {
    console.error(JSON.stringify(error));
    return null
  }
}
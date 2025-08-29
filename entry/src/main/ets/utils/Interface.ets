export interface Artist {
  id: string;
  name: string;
  coverArt: string;
  albumCount: number;
  artistImageUrl?: string;
  album?: Album[];
  biography?: string;
  starred?: string;
}

export interface SimilarArtist {
  id: string;
  name: string;
  albumCount: number;
  coverArt: string;
  artistImageUrl: string;
}

export interface ArtistInfo {
  biography: string;
  musicBrainzId: string;
  lastFmUrl: string;
  smallImageUrl: string;
  mediumImageUrl: string;
  largeImageUrl: string;
  similarArtist: SimilarArtist[];
}

export interface Index {
  name: string;
  artist: Artist[];
}

export interface Indexes {
  ignoredArticles: string;
  index: Index[];
}

export interface AlbumList {
  album: Album[];
}

export interface SubsonicResponse {
  status: string;
  version: string;
  type: string;
  serverVersion: string;
  openSubsonic: boolean;
  indexes?: Indexes;
  artist?: Artist;
  album?: Album;
  song?: Song;
  albumList?: AlbumList;
  playlists?: Playlists;
  playlist?: Playlist;
  artistInfo?: ArtistInfo;
  lyricsList?: LyricsList;
  starred?: Starred;
  shares?: Shares;
  searchResult2?: SearchResult;
  musicFolders?: MusicFolders;
}

export interface MusicFolders {
  musicFolder: MusicFolder[];
}

export interface MusicFolder {
  id: number;
  name: string;
}

export interface ApiResponse {
  "subsonic-response": SubsonicResponse;
}

export interface Album {
  id: string;
  parent: string;
  isDir: boolean;
  title: string;
  name: string;
  album: string;
  artist: string;
  year?: number;
  genre?: string;
  coverArt: string;
  duration: number;
  created: string;
  artistId: string;
  songCount: number;
  isVideo: boolean;
  bpm: number;
  comment: string;
  sortName: string;
  mediaType: string;
  musicBrainzId: string;
  genres: string[];
  replayGain: object;
  channelCount: number;
  samplingRate: number;
  song?: Song[];
  starred?: string;
}

export interface Song {
  id: string;
  parent: string;
  isDir: boolean;
  title: string;
  album: string;
  artist: string;
  track?: number;
  year: number;
  genre: string;
  coverArt: string;
  size: number;
  contentType: string;
  suffix: string;
  starred?: string;
  duration: number;
  bitRate: number;
  path: string;
  discNumber?: number;
  created: string;
  albumId: string;
  artistId: string;
  type: string;
  isVideo: boolean;
  bpm: number;
  comment: string;
  sortName: string;
  mediaType: string;
  musicBrainzId: string;
  genres: Genre[];
  replayGain?: ReplayGain;
  channelCount: number;
  samplingRate: number;
  transcodedContentType?: string;
  transcodedSuffix?: string;
}

export interface Genre {
  name: string;
}

export interface ReplayGain {
  trackGain?: number;
  trackPeak: number;
  albumPeak: number;
}

export interface Playlists {
  playlist?: Playlist[]
}

export interface Playlist {
  id: string;
  name: string;
  comment: string;
  songCount: number;
  duration: number;
  public: boolean;
  owner: string;
  created: string;
  changed: string;
  coverArt: string;
  entry?: Song[]
}

export interface LyricsList {
  structuredLyrics?: StructuredLyric[];
}

export interface StructuredLyric {
  displayArtist: string;
  displayTitle: string;
  lang: string;
  line: Line[];
  synced: boolean;
}

export interface Line {
  start?: number;
  value: string
}

export interface Starred {
  artist?: Artist[];
  album?: Album[];
  song?: Song[];
}

export interface Share {
  entry: Song[];
  id: string;
  url: string;
  description: string;
  username: string;
  created: string;
  expires: string;
  lastVisited: string;
  visitCount: number;
}

export interface Shares {
  share: Share[];
}

export interface SearchResult {
  song?: Song[];
  album?: Album[];
  artist?: Artist[];
}

export interface SaveState {
  nowPlayingSong: Song | undefined;
  nowPlayingLyrics: StructuredLyric | undefined;
  nowPlayingLyricsByGroup: Line[][];
  nowPlayingList: Song[];
  nowPlayingListOriginal: Song[];
  nowPlayingIndex: number;
  lyricsIndex: number;
  startPlaying: boolean;
  isPlaying: boolean;
  nowPlayedTime: number;
}

export interface Verse {
  id: number;
  uuid: string;
  hitokoto: string;
  type: string;
  from: string;
  from_who: string;
  creator: string;
  creator_uid: number;
  reviewer: number;
  commit_from: string;
  created_at: string;
  length: number;
}
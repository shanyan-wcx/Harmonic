export interface Artist {
  id: string;
  name: string;
  coverArt: string;
  albumCount: number;
  artistImageUrl?: string;
  album?: Album[];
  biography?: string
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

export interface SubsonicResponse {
  status: string;
  version: string;
  type: string;
  serverVersion: string;
  openSubsonic: boolean;
  indexes?: Indexes;
  artist?: Artist;
  album?: Album;
  playlists?: Playlists;
  playlist?: Playlist;
  artistInfo?: ArtistInfo;
  lyricsList?: LyricsList;
  starred?: Starred;
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
  year: number;
  genre: string;
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
}

export interface Song {
  id: string;
  parent: string;
  isDir: boolean;
  title: string;
  album: string;
  artist: string;
  track: number;
  year: number;
  genre: string;
  coverArt: string;
  size: number;
  contentType: string;
  suffix: string;
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
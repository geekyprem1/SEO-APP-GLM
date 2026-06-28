/**
 * YouTube Data API v3 provider.
 * API key is stored server-side.
 *
 * To set the API key:
 *   firebase functions:secrets:set YOUTUBE_API_KEY
 */

const { google } = require('googleapis');

const DEFAULT_MAX_RESULTS = 10;

/**
 * Returns an authenticated YouTube client.
 */
function getYouTubeClient() {
  const apiKey = process.env.YOUTUBE_API_KEY;
  if (!apiKey) {
    throw new Error('YOUTUBE_API_KEY is not set. Run: firebase functions:secrets:set YOUTUBE_API_KEY');
  }

  return google.youtube({
    version: 'v3',
    auth: apiKey,
  });
}

/**
 * Extracts the 11-char video ID from a YouTube URL.
 */
function extractVideoId(urlOrId) {
  if (urlOrId.length === 11) return urlOrId;

  const patterns = [
    /youtube\.com\/shorts\/([\w-]{11})/,
    /youtu\.be\/([\w-]{11})/,
    /[?&]v=([\w-]{11})/,
  ];

  for (const pattern of patterns) {
    const match = urlOrId.match(pattern);
    if (match) return match[1];
  }

  return null;
}

/**
 * Fetches full metadata for a single video.
 */
async function fetchVideo(videoUrlOrId) {
  const youtube = getYouTubeClient();
  const videoId = extractVideoId(videoUrlOrId);

  if (!videoId) {
    throw new Error('Invalid YouTube URL.');
  }

  const response = await youtube.videos.list({
    part: ['snippet', 'statistics', 'contentDetails'],
    id: [videoId],
  });

  if (!response.data.items || response.data.items.length === 0) {
    throw new Error('Video not found.');
  }

  const item = response.data.items[0];
  const snippet = item.snippet || {};
  const stats = item.statistics || {};

  return {
    videoId,
    title: snippet.title || '',
    description: snippet.description || '',
    channelId: snippet.channelId,
    channelTitle: snippet.channelTitle,
    thumbnailUrl: snippet.thumbnails?.high?.url || snippet.thumbnails?.default?.url,
    tags: snippet.tags || [],
    viewCount: stats.viewCount ? parseInt(stats.viewCount, 10) : null,
    likeCount: stats.likeCount ? parseInt(stats.likeCount, 10) : null,
    commentCount: stats.commentCount ? parseInt(stats.commentCount, 10) : null,
    publishedAt: snippet.publishedAt,
  };
}

/**
 * Fetches channel information.
 */
async function fetchChannel(channelId) {
  const youtube = getYouTubeClient();

  const response = await youtube.channels.list({
    part: ['snippet', 'statistics'],
    id: [channelId],
  });

  if (!response.data.items || response.data.items.length === 0) {
    throw new Error('Channel not found.');
  }

  const item = response.data.items[0];
  const snippet = item.snippet || {};
  const stats = item.statistics || {};

  return {
    channelId,
    title: snippet.title || '',
    description: snippet.description || '',
    thumbnailUrl: snippet.thumbnails?.high?.url || snippet.thumbnails?.default?.url,
    subscriberCount: stats.subscriberCount ? parseInt(stats.subscriberCount, 10) : null,
    videoCount: stats.videoCount ? parseInt(stats.videoCount, 10) : null,
    viewCount: stats.viewCount ? parseInt(stats.viewCount, 10) : null,
  };
}

/**
 * Searches YouTube for videos.
 */
async function searchVideos(query, maxResults = DEFAULT_MAX_RESULTS) {
  const youtube = getYouTubeClient();

  const response = await youtube.search.list({
    part: ['snippet'],
    q: query,
    maxResults,
    type: ['video'],
  });

  const items = response.data.items || [];

  return items.map((item) => ({
    videoId: item.id?.videoId || '',
    title: item.snippet?.title || '',
    channelTitle: item.snippet?.channelTitle,
    thumbnailUrl: item.snippet?.thumbnails?.high?.url || item.snippet?.thumbnails?.default?.url,
    publishedAt: item.snippet?.publishedAt,
  }));
}

module.exports = { fetchVideo, fetchChannel, searchVideos, extractVideoId };

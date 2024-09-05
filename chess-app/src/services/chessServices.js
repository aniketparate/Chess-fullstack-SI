import { fetchData, postData } from "./chessApiService";

const PLAYERS_ENDPOINT = 'performances';
const WINNERS_ENDPOINT = 'mostwins';
const MATCH_ENDPOINT = 'addmatch';
const COUNTRY_ENDPOINT = 'playersbycountry';

export const getPlayers = async () => {
  try {
    const data = await fetchData(PLAYERS_ENDPOINT);
    return data;
  } catch (error) {
    console.error('Failed to fetch players:', error.response?.data?.message || error.message);
    throw new Error('Could not retrieve player data at this time. Please try again later.');
  }
};

export const getWinners = async () => {
  try {
    const data = await fetchData(WINNERS_ENDPOINT);
    return data;
  } catch (error) {
    console.error('Failed to fetch winners:', error.response?.data?.message || error.message);
    throw new Error('Could not retrieve winners data at this time. Please try again later.');
  }
};

export const addMatch = async (match) => {
  try {
    const data = await postData(MATCH_ENDPOINT, match);
    console.log('Data from API:', JSON.stringify(data));
    return data;
  } catch (error) {
    console.error('Failed to add match:', error.response?.data?.message || error.message);
    throw new Error('Could not add match at this time. Please try again later.');
  }
};

export const getCountry = async (country, order) => {
  try {
    const endpoint = `${COUNTRY_ENDPOINT}?country=${country}&isDesc=${order}`;
    const data = await fetchData(endpoint);
    return data;
  } catch (error) {
    console.error('Failed to fetch players by country:', error.response?.data?.message || error.message);
    throw new Error('Could not retrieve country-specific player data at this time. Please try again later.');
  }
};

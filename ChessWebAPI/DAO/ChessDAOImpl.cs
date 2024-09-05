using ChessWebAPI.Models;
using Npgsql;
using System.Data;
using System.Numerics;

namespace ChessWebAPI.DAO
{
    public class ChessDAOImpl : IChessDAO
    {
        private readonly NpgsqlConnection _connection;

        public ChessDAOImpl(NpgsqlConnection connection)
        {
            _connection = connection;
        }

        public async Task<bool> PlayerExists(int playerId)
        {
            string query = "SELECT COUNT(*) FROM chess.players WHERE player_id = @playerId";

            try
            {
                await _connection.OpenAsync();
                var cmd = new NpgsqlCommand(query, _connection);

                using (cmd)
                {
                    cmd.Parameters.AddWithValue("playerId", playerId);
                    var result = (long)(await cmd.ExecuteScalarAsync() ?? 0);
                    return result > 0;
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                return false;
            }
            finally
            {
                await _connection.CloseAsync();
            }
        }

        public async Task<int> AddMatch(AddMatch request)
        {
            int rowsInserted = 0;
            string message = null;

            bool playersExist = await PlayerExists(request.Player1Id) && await PlayerExists(request.Player2Id);
            if (!playersExist)
            {
                return rowsInserted;
            }

            string insertQuery = @"INSERT INTO chess.matches (player1_id, player2_id, match_date, match_level, winner_id) 
                            VALUES (@player1Id, @player2Id, @matchDate, @matchLevel, @winnerId)";

            try
            {
                using (_connection)
                {
                    await _connection.OpenAsync();

                    using (var insertCommand = new NpgsqlCommand(insertQuery, _connection))
                    {
                        insertCommand.Parameters.AddWithValue("@player1Id", NpgsqlTypes.NpgsqlDbType.Integer, request.Player1Id);
                        insertCommand.Parameters.AddWithValue("@player2Id", NpgsqlTypes.NpgsqlDbType.Integer, request.Player2Id);
                        insertCommand.Parameters.AddWithValue("@matchDate", NpgsqlTypes.NpgsqlDbType.Date, request.MatchDate);
                        insertCommand.Parameters.AddWithValue("@matchLevel", NpgsqlTypes.NpgsqlDbType.Text, request.MatchLevel);
                        insertCommand.Parameters.AddWithValue("@winnerId", request.WinnerId.HasValue ? (object)request.WinnerId.Value : DBNull.Value);

                        rowsInserted = await insertCommand.ExecuteNonQueryAsync();
                    }
                }
            }
            catch (NpgsqlException e)
            {
                message = e.Message;
                Console.WriteLine($"An error occurred while inserting match details: {message}");
            }
            catch (Exception e)
            {
                message = e.Message;
                Console.WriteLine($"An unexpected error occurred: {message}");
            }

            return rowsInserted;
        }


        public async Task<List<PlayerPerformance>> GetPlayerPerformances()
        {
            string errorMessage = null;
            List<PlayerPerformance> playerPerformances = new List<PlayerPerformance>();

            string query = @"
                SELECT 
                    p.player_id,
                    p.first_name || ' ' || p.last_name AS full_name,
                    COUNT(m.match_id) AS total_matches,
                    COUNT(CASE WHEN m.winner_id = p.player_id THEN 1 END) AS total_wins,
                    COALESCE(
                        ROUND(
                            (COUNT(CASE WHEN m.winner_id = p.player_id THEN 1 END)::decimal / COUNT(m.match_id)) * 100, 2
                        ), 0
                    ) AS win_percentage
                FROM chess.players p
                LEFT JOIN chess.matches m ON p.player_id = m.player1_id OR p.player_id = m.player2_id
                GROUP BY p.player_id, p.first_name, p.last_name
                ORDER BY win_percentage DESC, full_name";

            try
            {
                using (_connection)
                {
                    await _connection.OpenAsync();
                    NpgsqlCommand command = new NpgsqlCommand(query, _connection);
                    command.CommandType = CommandType.Text;
                    NpgsqlDataReader reader = await command.ExecuteReaderAsync();
                    if (reader.HasRows)
                    {
                        while (await reader.ReadAsync())
                            {
                                playerPerformances.Add(new PlayerPerformance
                                {
                                    PlayerId = reader.GetInt32(0),
                                    FullName = reader.GetString(1),
                                    TotalMatches = reader.GetInt32(2),
                                    TotalWins = reader.GetInt32(3),
                                    WinPercentage = reader.GetDecimal(4)
                                });
                            }
                    }
                }
            }
            catch (NpgsqlException e)
            {
                errorMessage = e.Message;
                Console.WriteLine("Database exception occurred: " + errorMessage);
            }
            catch (Exception e)
            {
                errorMessage = e.Message;
                Console.WriteLine("An unexpected error occurred: " + errorMessage);
            }

            return playerPerformances;
        }


        public async Task<List<PlayerDetails>> GetPlayersByCountry(string country, bool isDesc)
        {
            string? errorMessage = null;
            List<PlayerDetails> players = new List<PlayerDetails>();

            string query = $@"SELECT 
                        player_id, first_name, last_name, country, current_world_ranking, total_matches_played
                      FROM 
                        chess.players 
                      WHERE 
                        country ilike @Country
                      ORDER BY 
                        current_world_ranking 
                      {(isDesc ? "DESC" : "ASC")}";

            try
            {
                using (_connection)
                {
                    await _connection.OpenAsync();
                    NpgsqlCommand command = new NpgsqlCommand(query, _connection);
                    command.CommandType = CommandType.Text;
                    command.Parameters.AddWithValue("@Country", country);
                    NpgsqlDataReader reader = await command.ExecuteReaderAsync();
                    if (reader.HasRows)
                    {
                        while (await reader.ReadAsync())
                        {
                            PlayerDetails player = new PlayerDetails
                            {
                                PlayerId = reader.IsDBNull(0) ? -1 : reader.GetInt32(0),
                                FirstName = reader.IsDBNull(1) ? null : reader.GetString(1),
                                LastName = reader.IsDBNull(2) ? null : reader.GetString(2),
                                Country = reader.IsDBNull(3) ? null : reader.GetString(3),
                                CurrentWorldRanking = reader.IsDBNull(4) ? -1 : reader.GetInt32(4),
                                TotalMatchesPlayed = reader.IsDBNull(5) ? -1 : reader.GetInt32(5)
                            };
                            players.Add(player);
                        }
                    }
                }
            }
            catch (NpgsqlException e)
            {
                errorMessage = e.Message;
                Console.WriteLine("Database exception occurred: " + errorMessage);
            }
            catch (Exception e)
            {
                errorMessage = e.Message;
                Console.WriteLine("An unexpected error occurred: " + errorMessage);
            }

            return players;
        }


        public async Task<List<PlayerPerformance>> GetPlayersWithMostWins()
        {
            string errorMessage = null;
            List<PlayerPerformance> players = new List<PlayerPerformance>();

            string query = @"
                    WITH average_wins AS (
                        SELECT AVG(total_wins) AS avg_wins
                        FROM (
                            SELECT COUNT(CASE WHEN m.winner_id = p.player_id THEN 1 END) AS total_wins
                            FROM chess.players p
                            LEFT JOIN chess.matches m ON p.player_id = m.player1_id OR p.player_id = m.player2_id
                            GROUP BY p.player_id
                        )
                    )
                    SELECT 
                        p.player_id,
                        p.first_name || ' ' || p.last_name AS full_name,
                        COUNT(CASE WHEN m.winner_id = p.player_id THEN 1 END) AS total_wins,
                        COALESCE(
                            ROUND(
                                (COUNT(CASE WHEN m.winner_id = p.player_id THEN 1 END)::decimal / COUNT(m.match_id)) * 100, 2
                            ), 0
                        ) AS win_percentage
                    FROM 
                        chess.players p
                    LEFT JOIN 
                        chess.matches m ON p.player_id = m.player1_id OR p.player_id = m.player2_id
                    GROUP BY 
                        p.player_id, p.first_name, p.last_name
                    HAVING 
                        COUNT(CASE WHEN m.winner_id = p.player_id THEN 1 END) > (SELECT avg_wins FROM average_wins)
                    ORDER BY 
                        total_wins DESC";

            try
            {
                using (_connection)
                {
                    await _connection.OpenAsync();
                    NpgsqlCommand command = new NpgsqlCommand(query, _connection);
                    command.CommandType = CommandType.Text;
                    NpgsqlDataReader reader = await command.ExecuteReaderAsync();
                    if (reader.HasRows)
                    {
                        while (await reader.ReadAsync())
                        {
                            players.Add(new PlayerPerformance
                            {
                                PlayerId = reader.GetInt32(0),
                                FullName = reader.GetString(1),
                                TotalWins = reader.GetInt32(2),
                                WinPercentage = reader.GetDecimal(3)
                            });
                        }
                    }
                }
            }
            catch (NpgsqlException e)
            {
                errorMessage = e.Message;
                Console.WriteLine("Database exception occurred: " + errorMessage);
            }
            catch (Exception e)
            {
                errorMessage = e.Message;
                Console.WriteLine("An unexpected error occurred: " + errorMessage);
            }

            return players;
        }
    }
}

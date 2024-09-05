using ChessWebAPI.Models;
using System.Numerics;

namespace ChessWebAPI.DAO
{
    public interface IChessDAO
    {
        Task<int> AddMatch(AddMatch request);

        Task<List<PlayerDetails>> GetPlayersByCountry(string country, bool isDesc);

        Task<List<PlayerPerformance>> GetPlayerPerformances();

        Task<List<PlayerPerformance>> GetPlayersWithMostWins();
    }
}

using ChessWebAPI.DAO;
using ChessWebAPI.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace ChessWebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ValuesController : ControllerBase
    {
        private readonly IChessDAO _chessDAO;
        public ValuesController(IChessDAO chessDAO) => _chessDAO = chessDAO;


        [HttpPost("addmatch", Name = "AddMatch")]
        public async Task<IActionResult> AddMatch(AddMatch request)
        {
            if (request != null)
            {
                int result = await _chessDAO.AddMatch(request);
                if (result > 0)
                {
                    return CreatedAtRoute(nameof(AddMatch), new { id = request.WinnerId }, request);
                }
                return BadRequest("Failed to add product");
            }
            else
            {
                return BadRequest();
            }
        }

        [HttpGet("playersbycountry")]
        public async Task<IActionResult> GetPlayersByCountry([FromQuery] string country, [FromQuery] bool isDesc)
        {
            List<PlayerDetails> players = await _chessDAO.GetPlayersByCountry(country, isDesc);

            if (players == null || players.Count == 0)
            {
                return NotFound("No players found for the given country.");
            }

            return Ok(players);
        }

        [HttpGet("performances")]
        public async Task<IActionResult> GetPlayerPerformances()
        {
            List<PlayerPerformance> performances = await _chessDAO.GetPlayerPerformances();
            if (performances.Count > 0)
            {
                return Ok(performances);
            }
            else
            {
                return NotFound("No player performances found.");
            }
        }

        [HttpGet("mostwins")]
        public async Task<IActionResult> GetPlayersWithMostWins()
        {
            List<PlayerPerformance> players = await _chessDAO.GetPlayersWithMostWins();
            if (players.Count > 0)
            {
                return Ok(players);
            }
            else
            {
                return NotFound("No players found.");
            }
        }
    }
}

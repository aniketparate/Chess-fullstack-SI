namespace ChessWebAPI.Models
{
    public class PlayerPerformance
    {
        public int PlayerId { get; set; }
        public string? FullName { get; set; }
        public int TotalMatches { get; set; }
        public int TotalWins { get; set; }
        public decimal WinPercentage { get; set; }
    }
}

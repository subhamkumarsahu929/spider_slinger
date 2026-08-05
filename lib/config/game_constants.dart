class GameConstants {
  static const double gravity = 900.0;
  static const double playerSpeed = 250.0;
  static const double jumpForce = -550.0;

  // Asymmetric gravity — makes arcs feel snappy instead of floaty
  static const double fallMultiplier = 2.2;     // Applied when falling (v > 0)
  static const double lowJumpMultiplier = 1.4;  // Applied when rising but jump not held

  // Terminal velocity — prevents tunneling on lag spikes
  static const double maxFallSpeed = 1200.0;

  // Horizontal acceleration & friction — replaces instant velocity snap
  static const double acceleration = 1200.0; // pixels/s²
  static const double friction     = 1800.0; // pixels/s²

  // Pendulum swing — real rope physics (#5)
  static const double ropeLength   = 280.0;  // pixels from ceiling anchor to player
  static const double swingDamping = 0.6;    // exponential air-resistance coefficient
  static const double maxSwingHeight = -50.0; // Prevent infinite upwards swinging

  // Web shot arc — gentle gravity on fired webs (#9)
  static const double webArcGravity = 200.0; // pixels/s²

  static const int maxLives = 3;
  static const double invulnerabilityDuration = 2.0;

  // Scoring
  static const int scoreCrawler = 10;
  static const int scoreAirborne = 20;
  static const int scoreDodge = 15;
  static const int scoreFinish = 500;
  static const int scorePerLife = 100;

  // Difficulty limits
  static const double phase1Duration = 30.0;
  static const double phase2Duration = 45.0;
  
  // Damage
  static const int webShotDamage = 1;
}

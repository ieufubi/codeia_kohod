type
  TGameEngine = class
private
  FSecretNumber: Int64;
public:
  constructor Create(const SecretNum: Int64);
  destructor Destroy; override;
  // Méthode pour lancer le jeu de manière asynchrone.
  function StartGuessingGameAsync(): TTask;
  // Logique qui pourrait être appelée par des boutons UI ou timers.
  procedure ProcessUserAttempt(const Attempt: Int64);
end;
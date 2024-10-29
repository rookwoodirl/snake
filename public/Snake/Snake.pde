
int sl_screen = 500;  // screen dimensions
int sl_board = 7;     // how many squares per side for the board game
int sl_games = 10;    // how many games per side
int sq_size = sl_screen / sl_board / sl_games;

Game[] games;   // tracking the games going on

void setup() {
  size(sl_screen, sl_screen);
  
  games = new Game[sl_games * sl_games];
  
  for (int i = 0; i < sl_games; i++) {
    for (int j = 0; j < sl_games; j++) {
      games[i*sl_games + j] = new Game(j, i);
    }
  }
  
}

void draw() {
  for (Game game : games) {
    game.draw();
  }
}


class Game {
  float x, y;
  color col;
  Game(int x, int y) {
    // the pixel coordinates of the top left corner
    this.x = x * sq_size * sl_board;
    this.y = y * sq_size * sl_board;
    
    this.col = color(int(random(0, 255)), int(random(0, 255)), int(random(0, 255)));
  }
  void draw() {
    fill(this.col);
    stroke(0,0,0);
    
    for (int i = 0; i < sl_board; i++) {
      for (int j = 0; j < sl_board; j++) {
        rect(this.x + i * sq_size, this.y + j * sq_size, sq_size, sq_size);
      }
    }
  }
}

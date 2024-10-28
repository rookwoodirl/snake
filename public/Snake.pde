import java.util.Arrays;


Game g;
int frames = 0, nextMove = 0;
float speed = 1.0;
int sideLength;
int generation = 0;

int gridSize = 50;
int numParents = gridSize*gridSize/2;
int[] shape = { 8, 4 };


Game[] games = new Game[gridSize*gridSize];
SnakeMLP[] mlp = new SnakeMLP[gridSize*gridSize];



void setup() {
  size(700,700); 
  sideLength = int(width / gridSize);
  frameRate(10); // 20 fps
  
  mlp = makeSnakes(null);
  
}

void draw() {
  
  background(255);
  
  boolean allLoss = true;
  
  
  for (int i = 0; i < gridSize*gridSize; i++) {
    mlp[i].decide();
    mlp[i].move();
    mlp[i].game.draw();
    allLoss &= mlp[i].game.lose;
  }
  
  
  if (allLoss)
    mateSnakes();
  
  frames += 1;
}

void mateSnakes() {
  generation++;
  int[] scores = new int[gridSize*gridSize];
  
  for (int i = 0; i < mlp.length; i++)
    scores[i] = mlp[i].game.score;
  
    
  Arrays.sort(scores);
  SnakeMLP[] fitSnakes = new SnakeMLP[numParents];
  
  float total = 0;
  
  for (int i = 0; i < scores.length; i++)
    total += scores[i];
  println(generation, total / scores.length, scores[0], scores[scores.length-1]);
  int topX = scores[scores.length-fitSnakes.length];
  
  int idx = 0;
  for (SnakeMLP snake : mlp)
    if (snake.game.score >= topX && idx < fitSnakes.length) {
      fitSnakes[idx] = snake;
      snake.game.reset();
      idx++;
    }
  
  mlp = makeSnakes(fitSnakes);
  for (int i = 0; i < fitSnakes.length; i++) {
    SnakeMLP oldSnake = mlp[i];
    mlp[i] = fitSnakes[i];
    mlp[i].game = oldSnake.game;
    mlp[i].game.reset();
  }
  // introduce some genetic diversity
  for (int i = 0; i < 10; i++) {
    int randomSnake = int(random(numParents, mlp.length));
    mlp[randomSnake] = new SnakeMLP(shape, mlp[randomSnake].game);
  }
}


void reset() {
  frames = 0;
  nextMove = 0;
  speed = 1;
  setup();
}


/*
void keyPressed() {
  if (key == 'w' || key == 'W') {
    d = Direction.UP;
  }
  if (key == 's' || key == 'S') {
    d = Direction.DOWN;
  }
  if (key == 'a' || key == 'A') {
    d = Direction.LEFT;
  }
  if (key == 'd' || key == 'D') {
    d = Direction.RIGHT;
  }
  
  if (key == ' ')
    reset();
}
*/


SnakeMLP[] makeSnakes(SnakeMLP[] parents) {
  
  SnakeMLP[] newSnakes = new SnakeMLP[mlp.length];
  for (int y = 0; y < gridSize; y++) {
    for (int x = 0; x < gridSize; x++) {
       games[y*gridSize + x] = new Game(10, color(255,255,255), x*sideLength, y*sideLength, sideLength, sideLength);
       if (parents == null)
         newSnakes[y*gridSize + x] = new SnakeMLP(shape, games[y*gridSize + x]);
       else {
         SnakeMLP mom = parents[int(random(parents.length))];
         SnakeMLP dad = parents[int(random(parents.length))];
         newSnakes[y*gridSize + x] = mom.mate(dad);
         newSnakes[y*gridSize + x].game.reposition(x*sideLength, y*sideLength, sideLength, sideLength);
       }
    }
  }
  
  return newSnakes;
}

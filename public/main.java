public class Game {
  
  int BLANK = 0, HEAD = 1, BODY = 2, APPLE = 3;
  
  int id = int(random(0, 100));
  int boardSize = 7;
  int SCORE_INCREMENT = 1;
  
  
  int score = boardSize*boardSize;
  float[] state;
  
  float[] state() {
    return reducedState();
  }
  
  int isBody(int x, int y) {
    Body b = this.head;
    while(b != null) {
      if (b.x == x && b.y == y)
        return 1;
      b = b.next;
    }
    return -1;
  }
  
  float[] reducedState() {
    
    
    float[] state = {
      // location of apple
      this.apple.x / float(this.sideLength),
      this.apple.y / float(this.sideLength),
      
      // distance to walls, 4 directions
      this.head.x / float(this.sideLength),
      this.head.y / float(this.sideLength),
      
      
      // distance to body, 4 directions
      this.isBody(this.head.x - 1, this.head.y),
      this.isBody(this.head.x + 1, this.head.y),
      this.isBody(this.head.x, this.head.y - 1),
      this.isBody(this.head.x, this.head.y + 1),
      
    };
    
    return state;
    
  }
  
  class Body {
    int x, y; // coordinates
    Body prev, next;
    
    Body(int x, int y) {
      this.x = x;
      this.y = y;
      
    }
    
    
    boolean equals(Body b) {
      if (b == null)
        return false;
      return this.x == b.x && this.y == b.y;
    }
    
  }
  
  Body head, tail, apple;
  int snakeLength = 0;
  
  boolean lose = false;
  
  int sideLength;
  
  int x0, x1, y0, y1;
  float sqSize;
  
  color sqColor;
  
  void reset() {
    this.lose = false;
    this.newHead(2,3);
    this.newHead(3,3);
    this.tail = this.head.next;
    this.apple = new Body(0,0);
    this.apple();
    this.snakeLength = 0;
    this.score = boardSize*boardSize-1;
    this.state = this.state();
  }
  
  void lose() {
    this.lose = true;
    fill(255,255,255);
    rect(this.x0, this.y0, this.x1, this.y1);
  }
  
  public void reposition(int x0, int y0, int lenX, int lenY) {
    this.x0 = x0;
    this.x1 = x0+lenX;
    this.y0 = y0;
    this.y1 = y0+lenY;
    this.sqSize = lenX / this.sideLength;
    
  }
  
  private void _init(int sideLength, color sqColor, int x0, int y0, int lenX, int lenY) {
    
    this.sideLength = sideLength;
    this.reposition(x0, y0, lenX, lenY);
    
    this.sqColor = sqColor;
    this.sqColor = color(int(random(255)), int(random(255)), int(random(255)), 100);
    this.reset();
  }
  
  void apple() {
    this.apple.x = int(random(0, this.sideLength));
    this.apple.y = int(random(0, this.sideLength));
    
    
    Body b = this.head;
    
    while(b != null) {
      if (apple.equals(b)) {
        this.apple();
        break;
      }
      b = b.next;
    }
    
  }
  
  public Game(int sideLength, color sqColor, int x0, int y0, int lenX, int lenY) {
    this._init(this.boardSize, sqColor, x0, y0, lenX, lenY);
  }
  public Game(int sideLength, color sqColor) {
    this._init(this.boardSize, sqColor, 0, 0, width, height);
  }
  
  void draw() {
    
    // draw board
    fill(this.sqColor);
    stroke(color(0,0,0));
    for (int j = this.y0; j < this.y1; j += this.sqSize) {
      for (int i = this.x0; i < this.x1; i += this.sqSize) {
        rect(i, j, this.sqSize, this.sqSize);
      }
    }
    
    // draw body
    Body b = this.head;
    
    // draw apple
    fill(color(255,0,0));
    rect(this.apple.x * this.sqSize + this.x0, this.apple.y * this.sqSize + this.y0, this.sqSize, this.sqSize);
    
    fill(color(0,0,255));
    while (b != null) {
      rect(b.x * this.sqSize + this.x0, b.y * this.sqSize + this.y0, this.sqSize, this.sqSize);
      b = b.next;
    }
    
  }
  
  void newHead(int x, int y) {
    
    if (x < 0 || y < 0 || x >= this.sideLength || y >= this.sideLength) {
      this.score = -1000;
      this.lose();
      return;
    }
    
    Body newHead = new Body(x, y);
    newHead.next = this.head;
    if (this.head != null)
      this.head.prev = newHead;
    this.head = newHead;
  }
  void dropTail() {
    this.tail = this.tail.prev;
    this.tail.next = null;
  }
  
  void move(int x, int y) {
    
    
    if (this.lose)
      return;
    
    newHead(x + this.head.x, y + this.head.y);
    
    if (this.lose)
      return;

    
    if (!this.head.equals(this.apple)) {
      // remove reference to tail
      this.dropTail();
    }
    else { // keep tail, new apple
      // new apple
      this.apple();
      this.score += SCORE_INCREMENT;
    }
    
    
    // check for loss
    Body b = this.head.next;
    
    while (b != null) {
      if (this.head.equals(b)) {
        this.score -= SCORE_INCREMENT*10;
        this.lose();
        return;
      }
      b = b.next;
    }
    
    this.state = this.state();
    
    
    if (this.score <= 0)
      this.lose();
      
    this.score -= SCORE_INCREMENT;
    
  }
  
}


// *** //


class Node {
  Node[] targets;
  float[] weights;
  
  void randomizeWeights() {
    for (int i = 0; i < targets.length; i++) {
      if (random(1) > 0.8) {
        this.weights[i] = random(-1.0,1.0);
        break;
      }
    }
  }
  
  
  Node(Node[] targets) {
    this.targets = targets;
    
    if (targets != null) {
      this.weights = new float[targets.length];
      for (int i = 0; i < this.weights.length; i++)
        this.weights[i] = random(-1, 1);
    }
  }
  
  float activation(float x) {
    return 1 / (1 + pow(2.716, -1*x));
  }
  
  float value() {
    float v = 0;
    for(int i = 0; i < this.targets.length; i++) {
      v += targets[i].value() * weights[i];
    }
    
    return activation(v);
  }
}

class InputNode extends Node {
    InputNode(Game g, int m) {
        this.g = g;
        this.m = m;
    }

    float value() {
        return g[m];
    }
}

// *** //

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

// *** //


enum Direction { UP, DOWN, LEFT, RIGHT };
class SnakeMLP {
  int id = int(random(0,100));
  Node[] inputs;
  Node[][] hiddenLayers;
  int[] shape;
  
  int boardSize = 10;
  
  Game game;
  
  
  Direction d = Direction.UP;
  
  
  void move() {
    if (d == Direction.UP)
      this.game.move(0,-1);
    else if (d == Direction.DOWN)
      this.game.move(0,1);
    else if (d == Direction.LEFT)
      this.game.move(-1,0);
    else if (d == Direction.RIGHT)
      this.game.move(1,0);
  }
  
  
  
  
  void decide() {
    if (this.game.lose)
      return;
  
    float[] values = this.values();
    
    int idx = 0;
    float greatest = values[0];
    for (int i = 1; i < values.length; i++)
      if (values[i] > greatest) {
        idx = i;
        greatest = values[i];
      }
    
    if (idx == 0) {
      d = Direction.UP;
    }
    else if (idx == 1) {
      d = Direction.DOWN;
    }
    else if (idx == 2) {
      d = Direction.LEFT;
    }
    else if (idx == 3) {
      d = Direction.RIGHT;
    }
    
  }
  
  float[] values() {
    Node[] outputs = this.hiddenLayers[this.hiddenLayers.length-1];
    float[] out = new float[outputs.length];
    
    for (int i = 0; i < out.length; i++)
      out[i] = outputs[i].value();
      
    return out;
  }
  
  void _init(int[] shape, Game g) {
    this.game = g;
    float[] state = g.state();
    this.inputs = new InputNode[state.length];
    this.shape = shape;
    
    
    for (int j = 0; j < state.length; j++) {
      int m = j;
      this.inputs[j] = new InputNode(g, m);
    }
    
    Node[] prevLayer = this.inputs;
    this.hiddenLayers = new Node[shape.length][];
    for (int i = 0; i < shape.length; i++) {
      this.hiddenLayers[i] = new Node[shape[i]];
      for (int j = 0; j < shape[i]; j++) {
        this.hiddenLayers[i][j] = new Node(prevLayer);
      }
      prevLayer = this.hiddenLayers[i];
    }
    
  }
  
  SnakeMLP(int[] shape, Game g) {
    this._init(shape, g);
  }
  
  SnakeMLP(int[] shape) {
    this._init(shape, new Game(this.boardSize, color(255,255,255)));
  }
  
  void mutate(int mutations) {
    for (int i = 0; i < mutations; i++) {
      Node[] randomLayer = this.hiddenLayers[int(random(0, this.hiddenLayers.length))];
      Node randomNode = randomLayer[int(random(0, randomLayer.length))];
      float[] weights = randomNode.weights;
      weights[int(random(0, weights.length))] = randomNode.activation(random(-1, 1));
    }
  }
  
  SnakeMLP mate(SnakeMLP partner) {
    
    SnakeMLP child = new SnakeMLP(this.shape);
    
    for (int i = 0; i < this.hiddenLayers.length; i++) {
      int pivot = int(random(0, this.hiddenLayers.length-1))+1;
      
      
      child.hiddenLayers[i] = (Node[]) concat(subset(this.hiddenLayers[i], 0, pivot), subset(partner.hiddenLayers[i], pivot, partner.hiddenLayers[i].length-pivot));
      
      if (random(0,1) > 0.8)
          child.mutate(int(random(0,10)));
    }
    
    return child;
    
  }
  
  
  
}

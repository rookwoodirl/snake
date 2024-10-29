

int sl_board = 7;     // how many squares per side for the board game
int sl_games = 20;    // how many games per side
int sl_screen;
float sq_size;
int[] shape;


Game[] games;   // tracking the games going on
int generation = 0;

void setup() {
  frameRate(10);
  
  size(800, 800);
  sl_screen = width;
  sq_size = float(sl_screen) / sl_board / sl_games;
  shape = new int[] { 8, 4 };
  
  games = new Game[sl_games * sl_games];
  
  for (int i = 0; i < sl_games; i++) {
    for (int j = 0; j < sl_games; j++) {
      Game g = new Game(j, i);
      g.player = new MLP(shape, g);
      games[i*sl_games + j] = g;
      
    }
  }
  
}

void draw() {
  for (Game game : games) {
    game.draw();
  }
    
  
  boolean anyone_playing = false;
  
  for (int i = 0; i < games.length; i++)
    anyone_playing |= games[i].playing;
    
    
  if  (!anyone_playing) {
    int[] scores = new int[games.length];
    for (int i = 0; i < games.length; i++)
      scores[i] = games[i].score;
      
    sort(scores);
    int num_parents = int(scores.length * 0.1);
    int threshhold = scores[scores.length - num_parents - 1];
    MLP[] parents = new MLP[num_parents];
    
    int parents_found = 0;
    int idx = 0;
    
    while (idx < games.length && parents_found < num_parents) {
      if (games[idx].score >= threshhold) {
        parents[parents_found] = games[idx].player;
        parents_found++;
      }
      idx++;
    }
    while (parents_found < num_parents) {
      parents[parents_found] = parents[0];
      parents_found++;
    }
    
    for (int i = 0; i < games.length; i++) {
      if (games[i].score <= threshhold) { // <= in case the entire population failed
        games[i].player = new MLP(shape, games[i]);
        MLP mom = parents[int(random(parents.length))];
        MLP dad = parents[int(random(parents.length))];
        
        games[i].player.mate(mom, dad);
        games[i].player.mutate(4);
      }
      
      games[i].reset();
      
    }
    generation += 1;
    println("generation: ", generation);
  }
  
  
}

class InputNode extends Node {
  float[] state;
  int idx;
  
  InputNode(float[] state, int idx) {
    super();
    this.state = state;
    this.idx = idx;
  }
  
  double value() {
    return this.state[this.idx];
  }
}

class MLP extends Player {
  
  Node[][] layers;
  Game game;
  int[] shape;
  
  MLP(int[] shape, Game game) {
    this.game = game;
    this.shape = shape;
    
    shape = concat(new int[] { game.state.length }, shape);
    this.layers = new Node[shape.length][];
    
    for (int i = 0; i < shape.length; i++) {
      this.layers[i] = new Node[shape[i]];
    }
    
    for (int i = 0; i < this.layers[0].length; i++)
      this.layers[0][i] = new InputNode(game.state, i);
      
    for (int i = 1; i < this.layers.length; i++) 
      for (int j = 0; j < this.layers[i].length; j++)
        this.layers[i][j] = new Node(this.layers[i-1]);
  }
  
  void mate(MLP mom, MLP dad) {
    for (int i = 1; i < this.shape.length; i++)
      for (int j = 0; j < this.shape[i]; j++) {
        float[] mom_weights = mom.layers[i][j].weights;
        float[] dad_weights = dad.layers[i][j].weights;
        this.layers[i][j].inherit(mom_weights, dad_weights);
      }
  }
  
  void mutate(int num_mutations) {
    for (int i = 0; i < num_mutations; i++) {
      Node[] random_layer = this.layers[int(random(1, this.layers.length))];
      random_layer[int(random(1, random_layer.length))].mutate(1);
    }
  }
  
  int[] decide() {
    double max = -10;
    int idx = -1;
    
    Node[] output_layer = this.layers[this.layers.length-1];
    for (int i = 0; i < output_layer.length; i++) {
      double val = output_layer[i].value();
      if (val > max) {
        max = val;
        idx = i;
      }
    }
    
    int[][] decisions = new int[][] {
      new int[] {-1, 0 },
      new int[] { 1, 0 },
      new int[] { 0,-1 },
      new int[] { 0, 1 }
    };
    
    return decisions[idx];
    
  }
  
}


class Node {
  Node[] inputs;
  float[] weights;
  
  Node() {
    this.weights = new float[] { 1.0 };
  }
  
  Node(Node[] inputs) {
    this.inputs = inputs;
    this.weights = new float[inputs.length];

    for (int i = 0; i < this.weights.length; i++)
      this.weights[i] = 0.0;
  }
  
  double activation(float val) {
    double j = 1.0 / (1.0 + Math.pow(2.71828, -1.0*val));
    return j;
  }
  
  double value() {
    float val = 0.0;
    for (int i = 0; i < this.inputs.length; i++)
      val += this.inputs[i].value() * this.weights[i];
      
    return this.activation(val);
  }
  
  void mutate(int num_mutations) {
    for (int i = 0; i < num_mutations; i++) {
      this.weights[int(random(this.weights.length))] = random(-1.0, 1.0);
    }
  }
  
  void inherit(float[] mom, float[] dad) {
    int pivot = int(random(0, mom.length));
    if (this.weights == null)
      return;
    for (int i = 0; i < pivot; i++) {
      this.weights[i] = mom[i];
    }
    for (int i = pivot; i < dad.length; i++) {
      this.weights[i] = dad[i];
    }
  }
  
}


class Body {
  float x, y;
  int board_x, board_y;
  Body prev, next;
  
  Body(int board_x, int board_y) {
     this.board_x = board_x;
     this.board_y = board_y;
  }
  
  Body move(int units_x, int units_y) {
    // link the list
    this.prev = new Body(this.board_x + units_x, this.board_y + units_y);
    this.prev.next = this;
      
    // return new head
    return this.prev;
    
  }
  
  void drop_tail() {
    // recursively pass through list looking for last element
    // it's O(n) but this is so much less hateful than tracking the tail
    if (this.next == null) {
      this.prev.next = null;
      this.prev = null;
    }
    else {
      this.next.drop_tail();
    }
  }
  
  void draw(float x0, float y0) {
    fill(0, 0, 255); // blue
    noStroke();
    rect(x0 + this.board_x*sq_size, y0 + this.board_y*sq_size, sq_size, sq_size);
    
    if (this.next != null)
      this.next.draw(x0, y0);
  }
  
}

class Player {
  Game game;
  
  int[][] pattern = new int[][] {
    new int[] { 0, 1 },
    new int[] { 1, 0 },
    new int[] { 0, -1 },
    new int[] { -1, 0 }
  };
  int idx = 0;
  
  int[] decide() {
    this.idx += 1;
    if (this.idx == this.pattern.length)
      this.idx = 0;
      
    return this.pattern[this.idx];

  }
}

class Game {
  float x, y;
  int apple_x, apple_y;
  float[] state;
  color col;
  int score;
  boolean playing = true;
  MLP player;
  Body head;
  Game(int x, int y) {
    // the pixel coordinates of the top left corner
    this.x = x * sq_size * sl_board;
    this.y = y * sq_size * sl_board;
    
    this.col = color(int(random(0, 255)), int(random(0, 255)), int(random(0, 255)));
    
    this.reset();
    
  }
  
  void reset() {
    this.score = 0;
    this.head = new Body(int(sl_board / 2), int(sl_board / 2));
    this.new_apple();
    this.state = this.get_state();
    this.playing = true;
    
  }
  
  void new_apple() {
    this.apple_x = int(random(sl_board));
    this.apple_y = int(random(sl_board));
  }
  
  float[] get_state() {
    return new float[] {
      float(this.apple_x) / sl_board,
      float(this.apple_y) / sl_board,
      float(this.head.board_x) / sl_board,
      float(this.head.board_y) / sl_board
    };
  }
  
  
  int move(int x, int y) {
      Body new_head = this.head.move(x, y);
      
      // check out-of-bounds
      if (new_head.board_x < 0 || new_head.board_x >= sl_board || new_head.board_y < 0 || new_head.board_y >= sl_board) {
        this.playing = false;
        return -1000;
      }
      
      
      this.head = new_head;
      
      if (this.head.board_x == this.apple_x && this.head.board_y == this.apple_y) {
        this.new_apple();
        return sl_board*sl_board + 1;
      }
      
      this.head.drop_tail();
      return 1;
    
  }
  
  void draw() {
    if (!this.playing)
      return;
      
    if (this.player != null) {
      int[] moves = this.player.decide();
      this.score += this.move(moves[0], moves[1]);
    }
    
    if (!this.playing)
      return;
      
    
    fill(this.col);
    stroke(0,0,0);
    
    for (int i = 0; i < sl_board; i++)
      for (int j = 0; j < sl_board; j++)
        rect(this.x + i * sq_size, this.y + j * sq_size, sq_size, sq_size);
    
    // draw apple
    fill(255, 0, 0); // red
    rect(this.x + this.apple_x * sq_size, this.y + this.apple_y * sq_size, sq_size, sq_size);
    
    // head recursively draws the rest
    this.head.draw(this.x, this.y);
    
  }
}

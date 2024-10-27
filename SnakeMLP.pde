
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
    this.inputs = new Node[state.length];
    this.shape = shape;
    
    
    for (int j = 0; j < state.length; j++) {
      int m = j;
      this.inputs[j] = new Node(null) {
        float value() {
          return g.state[m];
        }
      };
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

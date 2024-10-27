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

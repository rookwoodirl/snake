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

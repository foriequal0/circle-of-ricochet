final float outerRadius = 500;
final float innerRadius = 400;

final float bulletSpeed = 500;

final float centerX = 500;
final float centerY = 500;

class Movable{
  PVector pos;
  PVector vel;
  float radius;
  boolean check;
}

ArrayList<Movable> bullets = new ArrayList<Movable>();
ArrayList<Movable> moving = new ArrayList<Movable>();
Movable character = new Movable();

void addBullet(PVector pos, PVector direction){
  Movable m = new Movable();
  m.pos = pos;
  
  PVector vel = direction.get();
  vel.normalize();
  vel.mult(bulletSpeed);
  m.vel = vel;
  m.radius = 5;
  m.check = false;
  bullets.add(m);
  moving.add(m);
} 

void start(){
  size(1000, 1000);
  
  character.pos = new PVector();
  character.vel = new PVector();
  character.radius = 10;
  character.check = false;
  moving.add(character);
  
  lastmillis = millis();
}

void mousePressed(){
  int currmillis = millis();
  float dt = (currmillis - lastmillis)/1000.0;
  PVector mouse = new PVector(mouseX, mouseY);
  mouse.sub(centerX, centerY, 0);
  
  PVector diff = PVector.sub(mouse, character.pos);
  diff.normalize();
  PVector bulletStartPoint = PVector.add(character.pos, PVector.mult(diff, 20));
  PVector offset = PVector.mult(diff, dt);
  bulletStartPoint.add(offset);
  
  addBullet(bulletStartPoint, diff);
  
}

int lastmillis = 0;
float t = 0;

ArrayList<Movable> deleted = new ArrayList<Movable>();
void draw(){
  int currmillis = millis();
  float dt = (currmillis - lastmillis)/1000.0;
//  if(dt != 0.0);
//  t += dt;
//  if(t >= 1) {
//    while(t >= 1) t-=1;
//    
//    addBullet( new PVector(495/sqrt(2), 0), new PVector(0, 1000));
//  }
//  println(character.pos);
  moveCharacter(dt);
  move(dt);
  for(Movable m:bullets){
    if(m.check){
      deleted.add(m);
    }
  }
  for(Movable m:deleted){
    bullets.remove(m);
    moving.remove(m);
  }
  deleted.clear();
  
  lastmillis = currmillis;
  
  background(0);
  stroke(0,0,0,0);
  pushMatrix();
  translate(centerX, centerY);
  
  pushMatrix();
//  rotate(-PVector.angleBetween(character.pos, new PVector(100, 0)));
//  translate(-character.pos.x, -character.pos.y);
  fill(128);
  ellipse(0,0,outerRadius*2,outerRadius*2);
  fill(255);
  ellipse(0,0,innerRadius*2,innerRadius*2);
  
  stroke(255, 0, 0);
  fill(255, 0, 0);
  for(Movable m:bullets){
    pushMatrix();
    translate(m.pos.x, m.pos.y);
    ellipse(0, 0, m.radius*2, m.radius*2);
    popMatrix();
  }
  
  pushMatrix();
  if(warn == 0){
    stroke(0, 0, 0);
    fill(0, 0, 0);
  } else if(warn == 1){
    stroke(0, 128, 0);
    fill(0, 128, 0);
  } else if(warn == 2){
    stroke(0, 255, 0);
    fill(0, 255, 0);
  }
  translate(character.pos.x, character.pos.y);
  ellipse(0, 0, character.radius*2, character.radius*2);
  popMatrix();
  popMatrix();
  popMatrix();
}

int keyarray[] = new int[255];
int keycnt = 0;
void keyPressed(){
  int keyvalue = keyCode;
  for(int i=0; i<keycnt; i++){
    if(keyarray[i] == keyvalue) return;
  }
  keyarray[keycnt++] = keyvalue;
}

void keyReleased(){
  int keyvalue = keyCode;
  int i;
  for(i=0; i<keycnt; i++){
    if(keyarray[i] == keyvalue) break;
  }
  for(; i<keycnt-1; i++){
    keyarray[i] = keyarray[i+1];
  }
  if(keycnt > 0)
    keycnt--;
}

void moveCharacter(float dt){
  character.vel.x = 0;
  character.vel.y = 0;
  for(int i=0; i<keycnt; i++){
    switch(keyarray[i]){
      case 'A': character.vel.x =-100; break;
      case 'D': character.vel.x =100; break;
      case 'W': character.vel.y =-100; break;
      case 'S': character.vel.y =100; break;
    }
  }
}
int warn = 0;
void move(float dt){
  warn = 0;
  for(Movable m : moving){
    // distance travelled during dt
    PVector dist = PVector.mult(m.vel, dt);
    PVector nextPos = PVector.add(m.pos, dist);
    checkCollide(m, m.pos, nextPos);
    float limitRadius;
    if(m == character) limitRadius = innerRadius;
    else limitRadius = outerRadius;
  
    float collideRadius = limitRadius - m.radius;
    float a = pow(m.vel.x, 2) + pow(m.vel.y, 2);
    float b = m.pos.x * m.vel.x + m.pos.y * m.vel.y;
    float c = pow(m.pos.x, 2) + pow(m.pos.y, 2) - pow(collideRadius, 2);
    // partial time
    float ttc = (-b + sqrt(pow(b, 2) - a*c))/a;
    // collision position m.pos + pt * m.vel
    PVector cPos = PVector.add(m.pos, PVector.mult(m.vel, ttc));
            
    // update new velocity. v' = v - 2*(m.vel*cPos)/abs(cPos)/direction(cPos).
    PVector newVel = PVector.sub(
                        m.vel, 
                        PVector.mult(
                          cPos, 
                          2*PVector.dot(m.vel, cPos)/pow(cPos.mag(),2)));
    if(m != character){
      if(onTheLine(m, m.pos, nextPos)){
        if(warn < 2){
          warn = 2;
        }
      } else if(onTheLine(m, cPos, PVector.add(cPos, newVel))){
        if(warn < 1){
          warn = 1;
        }
      }
    }
    
    
    if(nextPos.mag() + m.radius > limitRadius){
      // remaining time
      float rt = dt - ttc;
      if(m == character && false){
        PVector tmpVel = PVector.sub(
                            m.vel, 
                            PVector.mult(
                              cPos, 
                              PVector.dot(m.vel, cPos)/pow(cPos.mag(),2)));
        PVector rDis = PVector.mult(tmpVel, rt);
        PVector tPos = PVector.add(cPos, rDis);
        tPos.normalize();
        tPos.mult(collideRadius*0.99);
        m.pos = tPos;
        m.vel.x = 0;
        m.vel.y = 0;
      } else {

        //println(newVel);
        PVector rDis = PVector.mult(newVel, rt);
        m.pos = PVector.add(cPos, rDis);
        m.vel = newVel;
      }
    } else {
      m.pos = nextPos;
    }
  }
}

boolean inside_square(PVector tgt, PVector center, float radius){
  return (tgt.x >= center.x - radius)
  && (tgt.x <= center.x + radius)
  && (tgt.y >= center.y - radius)
  && (tgt.y <= center.y + radius);
}

boolean inside_circle(PVector tgt, PVector center, float radius){
  return tgt.dist(center) <= radius;
}

boolean onTheLine(Movable m, PVector pos, PVector nextPos){
  PVector dp = PVector.sub(nextPos, pos);
  PVector dc = PVector.sub(character.pos, pos);
  float dist = abs(dp.cross( dc).mag())/dp.mag();
  if(dist > m.radius + character.radius){
    return false;
  } else if (degrees(PVector.angleBetween(dp,dc))>=90){
    return false;
  } else {
    return true;
  }
}

void checkCollide(Movable m, PVector pos, PVector nextPos){
  
  if(m.check) return;
  float distance = pos.dist(nextPos);
  float safe_distance = distance + m.radius + character.radius;
  if(!inside_circle(character.pos, pos, safe_distance) 
    || !inside_circle(character.pos, nextPos, safe_distance)){
      return;
  }
  
  if(inside_circle(character.pos, pos, m.radius + character.radius)){
    m.check = true;
    return;
  }
  if(inside_circle(character.pos, nextPos, m.radius + character.radius)){
    m.check = true;
    return;
  }
  if(onTheLine(m, pos, nextPos)){
    m.check = true;
  }
  
}

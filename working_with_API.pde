// === Draft version UI Mock-up (Processing.js version) with API===


import http.requests.*;
import processing.data.JSONObject;

Orb orb;
InputField input;
ArrayList<Message> chat = new ArrayList<Message>();

String apiKey;
String endpoint = "https://api.openai.com/v1/chat/completions";  

// === Orb === general class to display an orb
class Orb {
  float x, y, r, angle, speed; // orb movement and position
  Orb(float x, float y, float r) { //class constructor
    this.x = x; //to use after in other methods of this class
    this.y = y; 
    this.r = r;
    angle = random(TWO_PI); //an angle for moving
    speed = 0.01; //fixed speed
  }
  void update() { 
  angle += speed; 
}// function update to call contantly for animation
  void display() { //animation of ronation, to explore further for upgrade
    float dx = sin(angle) * 20;
    float dy = cos(angle) * 10;
    float alpha = 150 + 50 * sin(angle * 2);
    noStroke();
    for (int i = 0; i < 6; i++) {
      float rr = r * (1.0 - i * 0.15);
      fill(170 + i * 10, 200 + i * 5, 255, alpha - i * 25); //fill of colour to do: work with gradient and blinking
      ellipse(x + dx, y + dy, rr, rr); //updated position in x and y. TO DO: Work with animation, radius should be expand
    }
  }
}

// === Message class === 
class Message {
  String text;
  boolean fromUser;
  Message(String text, boolean fromUser) { //class constructor
    this.text = text; // reference to the object (Lecture 7)
    this.fromUser = fromUser;
  }
}

void setup() {
  size(800, 1000);
  smooth(8);
  
  apiKey = loadStrings("key.txt")[0].trim();
  
  orb = new Orb(width/2, height/2 - 100, 200); // new exemplar of class orb
  input = new InputField(width/2 - 250, height - 120, 500, 50);
}

void draw() {
  drawGradientBackground();
  orb.update();
  orb.display();
  drawMessageBlocks();
  input.display();
}

// === Background gradient ===
void drawGradientBackground() {
  for (int y = 0; y < height; y++) {
    float gradient = map(y, 0, height, 0, 1);
    int color1 = color(236, 232, 255);
    int color2 = color(190, 224, 255);
    stroke(lerpColor(color1, color2, gradient));
    line(0, y, width, y); //gradient background
  }
}

// helping function to wrap message text into lines
ArrayList<String> wrapText(String text, float maxWidth) {
  String[] words = splitTokens(text, " ");
  ArrayList<String> lines = new ArrayList<String>();
  String currentLine = "";

  for (String word : words) {
    String testLine = currentLine.equals("") ? word : currentLine + " " + word;
    if (textWidth(testLine) > maxWidth) {
      lines.add(currentLine);
      currentLine = word;
    } else {
      currentLine = testLine;
    }
  }

  if (!currentLine.equals("")) lines.add(currentLine);
  return lines;
}


// === Draw chat message blocks for UI draft ===
void drawMessageBlocks() { 
  float y = height/2 + 200;
  textSize(16);
  textAlign(LEFT, TOP);
  float padding = 15;
  float maxBubbleWidth = width * 0.45;  // ~45% of screen width max
  float lineSpacing = 5;

  for (int i = 0; i < chat.size(); i++) {
    Message message = chat.get(i);
    String msgText = message.text;

    // Get wrapped lines
    ArrayList<String> lines = wrapText(msgText, maxBubbleWidth - 2 * padding);
    float lineHeight = textAscent() + textDescent() + lineSpacing;
    float boxH = lines.size() * lineHeight + 2 * padding;

    // Compute width based on the longest line
    float boxW = 0;
    for (String line : lines) {
      boxW = max(boxW, textWidth(line));
    }
    boxW = constrain(boxW + 2 * padding, 100, maxBubbleWidth);

    // Bubble position: left or right
    float x = message.fromUser ? width/2 + 50 : width/2 - boxW - 50;

    // Bubble background
    fill(message.fromUser ? color(230, 240, 255) : color(255));
    stroke(200);
    rect(x, y, boxW, boxH, 12);

    // Draw text inside bubble with word wrapping
    fill(50);
    float textY = y + padding;
    for (String line : lines) {
      text(line, x + padding, textY);
      textY += lineHeight;
    }

    y += boxH + 10; // Space between messages
  }
}



// === Input Field ===
class InputField {
  float x, y, w, h;
  String placeholder = "What's your misunderstanding...";
  String value = "";
  boolean focused = false;
  int caret = 0;
  int lastBlink = 0;
  boolean caretOn = true;
  float diameter = 46;
  float gap = 10;

  InputField(float x, float y, float w, float h){
    this.x = x; this.y = y; this.w = w; this.h = h;
  }

  void display(){
    // field
    noStroke();
    fill(255, 255, 255, 230);
    rect(x, y, w, h, 14);

    if (millis() - lastBlink > 600){
      caretOn = !caretOn;
      lastBlink = millis();
    }

    textAlign(LEFT, CENTER);
    textSize(16);
    float tx = x + 14;
    float ty = y + h/2.0;

    if (value.length() == 0 && !focused) {
      fill(0,0,0,120);
      text(placeholder, tx, ty);
    } else {
      fill(0,0,0,220);
      text(value, tx, ty);
      if (focused && caretOn){
        float cx = tx + textWidth(value.substring(0, caret));
        stroke(70,100,140);
        line(cx, y + 10, cx, y + h - 10);
      }
    }

    // buttons x ↑ clear and submit
    float baseX = x + w + 20;
    drawRoundBtn(baseX + gap, y + h/2, diameter, color(#A8C7D8), "↑");
  
    drawRoundBtn(baseX + diameter + 2 * gap, y + h/2, diameter, color(#E8A7BC), "x");
  }

  void drawRoundBtn(float cx, float cy, float diam, color bg, String label){
    noStroke(); fill(bg);
    ellipse(cx, cy, diam, diam);
    fill(255); textAlign(CENTER, CENTER); textSize(18);
    text(label, cx, cy);
  }

  void mouseClicked(){
    focused = (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h);
    if (focused) {
      caret = value.length();
      caretOn = true;
      lastBlink = millis();
    }

    float baseX = x + w + 20;
    if (dist(mouseX, mouseY, baseX + gap, y + h/2) <= diameter/2.0) commit();           // ↑ send
    
    if (dist(mouseX, mouseY, baseX + 2 * gap, y + h/2) <= diameter/2.0) clearAll(); // clear
  }

  void keyTyped(){
    if (!focused) return;
    if (key >= 32 && key != CODED){
      insert(str(key));
    }
  }

  void keyPressed(){
    if (!focused) return;

    if (key == BACKSPACE || keyCode == BACKSPACE || keyCode == 8){
      if (caret > 0){
        value = value.substring(0, caret-1) + value.substring(caret);
        caret--;
      }
      return;
    }

    if (keyCode == DELETE){
      if (caret < value.length()){
        value = value.substring(0, caret) + value.substring(caret+1);
      }
      return;
    }

    if (keyCode == ENTER || keyCode == RETURN){
      commit();
      return;
    }

    if (key == CODED){
      if (keyCode == LEFT) caret = max(0, caret - 1);
      else if (keyCode == RIGHT) caret = min(value.length(), caret + 1);
    }
  }

  void insert(String s){
    value = value.substring(0, caret) + s + value.substring(caret);
    caret += s.length();
  }

  void clear(){
    value = "";
    caret = 0;
  }

 void commit(){
  String message = value.trim();
  if (message.length() == 0) return;

  chat.add(new Message(message, true)); // show user's message

  //  call API and get answer
  String response = getChatGptResponse(message);

  // show the repky in chat
  chat.add(new Message(response, false));

  clear(); // clear
}
}

// === Routing ===
void mouseClicked() { input.mouseClicked(); }
void keyTyped() { input.keyTyped(); }
void keyPressed() { input.keyPressed(); }

// === Helpers ===

void clearAll(){
  chat.clear();
}

// A function where we make the API call using the HTTP request library
String getChatGptResponse(String prompt) {
  // Create a JSON object for the request body
  JSONObject requestBody = new JSONObject();
  
  // Construct the messages as per OpenAI's ChatGPT API format
  JSONObject message = new JSONObject();
  message.setString("role", "user");
  // String modifiedPrompt = "visualize mapping" + prompt
  message.setString("content", prompt); // TO DO work with visualization and prompt engineering
  
  // Add the model and messages to the request body
  requestBody.setString("model", "gpt-4o-mini");  // model type
  requestBody.setJSONArray("messages", new JSONArray().setJSONObject(0,message));
  
  // Set up the HTTP request to OpenAI API
  PostRequest request = new PostRequest(endpoint);
  request.addData(requestBody.toString());
  request.addHeader("Authorization", "Bearer " + apiKey);
  request.addHeader("Content-Type", "application/json");
  
  // Send the POST request with the JSON body
  request.send();
  
  //Return the parsed response from the function parseGPTResponse();
  println(request.getContent());
  return parseGPTResponse(request.getContent());
} 

// Processing the JSON response from ChatGPT  
String parseGPTResponse(String responseBody) {
  if (responseBody != null && responseBody.length() > 0) { 
    JSONObject json = parseJSONObject(responseBody);
    String chatResponse = json.getJSONArray("choices")
      .getJSONObject(0).getJSONObject("message").getString("content");
    return chatResponse;
  } else {
    return "Invalid JSON string.";
  }
}

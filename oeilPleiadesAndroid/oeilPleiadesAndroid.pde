/**
 * <p>Ketai Sensor Library for Android: http://ketai.org</p>
 *
 * <p>Ketai Camera Features:
 * <ul>
 * <li>Interface for built-in camera</li>
 * <li>Access camera flash</li>
 * </ul>
 * <p>Updated: 2017-09-01 Daniel Sauter/j.duran</p>
 */
import android.os.Environment;
import ketai.camera.*;
import android.text.format.Time;
import android.content.Intent;
import android.net.Uri;
import android.content.Context;
import android.os.Build;

PImage logo1, titre1, bstart, bstop, switchcam;
PImage notreImage;
int videoSliceX;
int drawPositionX;


KetaiCamera cam;



void setup() {
  fullScreen();
  orientation(LANDSCAPE);
  background(128);
  logo1 = loadImage("logoPSOblack.jpg");
  titre1 = loadImage("titre.png");
  bstart=loadImage("bStart.png");
  bstop=loadImage("bStop.png");
  switchcam=loadImage("switchcam.png");

  imageMode(CENTER);
  textAlign(CENTER, CENTER);
  textSize(displayDensity * 25);
  cam = new KetaiCamera(this, 1920, 1080, 24);
  notreImage = createImage(1920, 1080, RGB);
  notreImage.loadPixels();
  initImageFileArray();
  // on prend la colonne de pixel au milieu de la camera
  videoSliceX = 1920 / 2;
  // on affiche a partir du bord droit
  drawPositionX = 1920 - 1;
}

void initImageFileArray()
{
  for (int i=0; i < notreImage.pixels.length; i++) {
    notreImage.pixels[i] = color(0, 0, 0, 0);
  }
}

void draw() {

  if (cam != null && cam.isStarted()) {
    cam.read();
    if (drawPositionX > 0)
    {
      for (int y = 0; y < 1080; y++) {
        // indice d'ecriture a l'ecran
        int setPixelIndex = y*1920 + drawPositionX;
        // indice de lecture de la camera
        int getPixelIndex = y*1920  + videoSliceX;
        notreImage.pixels[setPixelIndex] = cam.pixels[getPixelIndex];
      }
      notreImage.updatePixels();
      image(notreImage, width/2, height/2 );
      stroke(255, 0, 0);
      //   line(drawPositionX-1, 100, drawPositionX-1, 100+480);
      // on se decale de 1 pixel vers la gauche
      drawPositionX--;
    } else
    {
      saveFileImage();
    }
  }
  drawUI();
}
void saveFileImage()
{
  File file=null;
 Time now = new Time();
        now.setToNow();
        String sTime = now.format("%Y_%m_%d_%H_%M_%S");

  String filename = "pleiades-"+sTime+".jpg";
  File path =Environment.getExternalStoragePublicDirectory(
    Environment.DIRECTORY_DCIM);
    
    if (!path.exists()) path.mkdirs();
    
    File pathCam=new File(path,"Camera");
    if (pathCam.exists())
    
    
   file = new File(pathCam, filename);
   else
    file = new File(path, filename);
  print(file.getAbsolutePath());
  notreImage.save(file.getAbsolutePath());
  cam.stop();
  drawPositionX=1920-1;
  
  // Publish a new song.
  
  
  if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
    final Intent scanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
    final Uri contentUri = Uri.fromFile(file); 
    scanIntent.setData(contentUri);
    getContext().sendBroadcast(scanIntent);
} else {
    final Intent intent = new Intent(Intent.ACTION_MEDIA_MOUNTED, Uri.parse("file://" + Environment.getExternalStorageDirectory()));
    getContext().sendBroadcast(intent);
}

}

void onCameraPreviewEvent()
{
  cam.read();
}

void mousePressed()
{
  //Toggle Camera on/off
  if (mouseX < bstop.width && mouseY < 100)
  {
    if (cam.isStarted())
    {
      cam.stop();
      saveFileImage();
    } else
    {
      cam.start();
      print("cam started!!!!");
      background(128);
      initImageFileArray();
    }
  }

  if (mouseX < (bstop.width+switchcam.width+20) && mouseX > bstop.width && mouseY < 100)
  {
    if (cam.getNumberOfCameras() > 1)
    {
      cam.setCameraID((cam.getCameraID() + 1 ) % cam.getNumberOfCameras());
    }
  }
}

void drawUI()
{
  pushStyle();
  textAlign(LEFT);
  fill(0);
  stroke(255);
  rect(0, 0, width/3, 100);
  rect(width/3, 0, width/3, 100);

  rect((width/3)*2, 0, width/3, 100);

  fill(255);
  if (cam.isStarted())
    image(bstop, bstop.width/2, bstop.height/2);
  else
    image(bstart, bstart.width/2, bstart.height/2);

  if (cam.getNumberOfCameras() > 0)
  {
    image(switchcam, bstop.width+ switchcam.width/2+20, bstart.height/2);
    // text("Switch Camera", width/3 + 5, 80);
  }

  image(titre1, width/2, titre1.height/2);

  image(logo1, width-logo1.width, logo1.height/2);

  popStyle();
}

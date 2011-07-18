package es.tid.ehealth.mobtel.android.app.ui.emergency;

import java.util.Timer;
import java.util.TimerTask;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Vibrator;
import android.view.View;
import android.widget.ImageButton;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.ehealth.mobtel.android.R;
import es.tid.ehealth.mobtel.android.app.ui.UtilsTelecare;
import es.tid.ehealth.mobtel.android.common.components.AppActivity;

public class EmergencyCountDown extends AppActivity{
	
	private static final Logger logger = LoggerFactory.getLogger(EmergencyCountDown.class);
	private static final String EMEREGENCY_NUMBER = UtilsTelecare.emergencyNumber;
	private ImageButton countDowunImage;
	private ImageButton exitButton;
	private int count = 10;
	private Timer timing;
	private Vibrator v;
	
	/** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
		setContentView(R.layout.emergencycountdown);
		init();
    }

	private void init() {
		countDowunImage = (ImageButton) findViewById(R.id.countdownimage);
		countDowunImage.setImageResource(R.drawable.buttonred_on_big);
		countDowunImage.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
            	timing.cancel();
            	callToEmergencyNumber();
            }
			
		});
		exitButton = (ImageButton) findViewById(R.id.exitbutton);
		exitButton.setImageResource(R.drawable.exit_off_big);
		exitButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
            	logger.debug("Emergency button clicked");
            	//EntryPoint.launch(getApplicationContext());
            	timing.cancel();
            	finish();
            }
		});
		
		timing = new Timer();
        timing.schedule(new Updater(countDowunImage), 1000, 1000);
        v = (Vibrator) getSystemService(VIBRATOR_SERVICE);
        v.vibrate(1000);
 
	}

		

	public static void launch(Context context) {
		Intent i = new Intent(context,EmergencyCountDown.class);
		i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		context.startActivity(i);		
		
	}	
	
		
	private class Updater extends TimerTask {
        private final ImageButton subject;

        public Updater(ImageButton subject) {
            this.subject = subject;
        }

        @Override
        public void run() {
            subject.post(new Runnable() {

                public void run() {
                	
                	if (count == 0){
                		timing.cancel();
                		return;
                	}               	
                	
                	switch (count) {
					case 10:
						logger.debug("Emergency count down start");
						subject.setImageResource(R.drawable.countdown9_big);
						v.vibrate(500);
						break;
					case 9:
						subject.setImageResource(R.drawable.countdown8_big);
						v.vibrate(500);
						break;
					case 8:
						subject.setImageResource(R.drawable.countdown7_big);
						v.vibrate(500);
						break;
					case 7:
						subject.setImageResource(R.drawable.countdown6_big);
						v.vibrate(500);
						break;
					case 6:
						subject.setImageResource(R.drawable.countdown5_big);
						v.vibrate(500);
						break;
					case 5:
						subject.setImageResource(R.drawable.countdown4_big);
						v.vibrate(500);
						break;
					case 4:
						subject.setImageResource(R.drawable.countdown3_big);
						v.vibrate(500);
						break;
					case 3:
						subject.setImageResource(R.drawable.countdown2_big);
						v.vibrate(500);
						break;
					case 2:
						subject.setImageResource(R.drawable.countdown1_big);
						v.vibrate(500);
						break;
					case 1:
						logger.debug("Emergency count down finished");
						subject.setImageResource(R.drawable.buttonred_on_big);
						callToEmergencyNumber();						
						break;					
					}
                	count--;
                }
            });
        }
    }

	public void callToEmergencyNumber() {		

		try {			
			String number = EMEREGENCY_NUMBER;	
			if (number.startsWith(UtilsTelecare.UK_PREFIX)){
				//Do nothing
			}else if (!number.startsWith(UtilsTelecare.SPAIN_PREFIX)){
				number = UtilsTelecare.SPAIN_PREFIX+number;
			}
			startActivityCall(number);
			finish();
		}catch (Exception e) {
			logger.error("Error trying calling -> "+e);
		}
	}

	public void startActivityCall(String number) {
		logger.debug("Calling emergency number: "+number);
		Intent i = new Intent();
		i.setAction(Intent.ACTION_CALL);
		i.setData(Uri.parse("tel:" +number));
		startActivity(i);		
	}

}

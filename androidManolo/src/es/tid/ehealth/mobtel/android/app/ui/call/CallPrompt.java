package es.tid.ehealth.mobtel.android.app.ui.call;


import java.lang.reflect.Method;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.RemoteException;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageButton;
import android.widget.ImageView;

import com.android.internal.telephony.ITelephony;
import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.ehealth.mobtel.android.R;
import es.tid.ehealth.mobtel.android.app.listeners.CallStateListener;
import es.tid.ehealth.mobtel.android.app.ui.EntryPoint;
import es.tid.ehealth.mobtel.android.common.bo.Contact;
import es.tid.ehealth.mobtel.android.common.services.ContactService;
import es.tid.ehealth.mobtel.android.common.services.impl.ContactServiceImpl;


//I aint no dummy (prompt)


public class CallPrompt extends Activity {
	
	private static final Logger logger = LoggerFactory.getLogger(CallPrompt.class);


	private boolean success = false;
	
	private static String PHONE_CONTACT = "phoneContact";

	/**
	 * TelephonyManager instance used by this activity
	 */
	private TelephonyManager tm;

	/**
	 * AIDL access to the telephony service process
	 */
	private  com.android.internal.telephony.ITelephony telephonyService;

	/**
	 * Service to access contact data
	 */
	private ContactService contactS;
	
	private ImageView contactimageview;
	private String contactPhone ="";
	

	//instead of having subclasses with an overridden layout definition
	//i just set the layout based on pref
	//in the android source they usually subclass to set a different layout/functionality
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		    
		contactS = new ContactServiceImpl(this);
		// grab an instance of telephony manager
		tm = (TelephonyManager) getSystemService(TELEPHONY_SERVICE);
		logger.debug("Telephony Manager created in device: "+tm.getDeviceId());
		CallStateListener callStateListener = new CallStateListener(); 
		tm.listen(callStateListener, PhoneStateListener.LISTEN_CALL_STATE);  

		// connect to the underlying Android telephony system
		connectToTelephonyService();

		setContentView(R.layout.answercall);
		
		contactimageview = (ImageView) findViewById(R.id.contactimageview);
		
		Bundle extras = getIntent().getExtras();
	    contactPhone  = extras.getString(PHONE_CONTACT);
	    Contact contact = contactS.getContactByPhoneNumber(contactPhone);
		if (contact != null){
			contactimageview.setImageBitmap(contact.getPhotoBitmap());
		}		

		ImageButton answer = (ImageButton) findViewById(R.id.docallimage);

		answer.setOnClickListener(new OnClickListener() {
			public void onClick(View v){
				answer();
			}
		});

		ImageButton reject = (ImageButton) findViewById(R.id.hungcallimage);

		reject.setOnClickListener(new OnClickListener() {
			public void onClick(View v){
				reject();
			}
		});
		
		logger.debug("NUMERO ACTIVAS: "+tm.getCallState());

	}

	/**  For motion  based nav hardware -----
	 * The optical nav handles as a trackball also (Incredible/ADR6300)
	 * the motion is locked by this override, to stop conversion to dpad directional events
	 * we allow the click to pass through, it comes to key event dispatch as dpad center
	 */
	@Override public boolean dispatchTrackballEvent(MotionEvent event) {

		if (event.getAction() == MotionEvent.ACTION_MOVE) return true;

		return super.dispatchTrackballEvent(event);
	}

	/** From Tedd's source
	 * http://code.google.com/p/teddsdroidtools/source/browse/
	 * get an instance of ITelephony to talk handle calls with
	 */
	private void connectToTelephonyService() {
		logger.debug("Connect to the underlying Android telephony system");
		try
		{
			logger.debug("Connecting to TelephonyService: "+tm.getClass().getName());
			// "cheat" with Java reflection to gain access to TelephonyManager's ITelephony getter
			Class<?> c = Class.forName(tm.getClass().getName());
			Method m = c.getDeclaredMethod("getITelephony");
			m.setAccessible(true);
			logger.debug("Connecting to TelephonyService");
			telephonyService = (ITelephony) m.invoke(tm);
			
		} catch (Exception e) {
			e.printStackTrace();
			logger.error("FATAL ERROR: could not connect to telephony subsystem");
			logger.error("Exception object: "+e);
			finish();
		}
	}

	/**
	 * AIDL/ITelephony technique for answering the phones
	 */
	private void answerCallAidl() {
		try {
			telephonyService.silenceRinger();
			telephonyService.answerRingingCall();
		} catch (RemoteException e) {
			e.printStackTrace();
			logger.error("FATAL ERROR: call to service method answerRiningCall failed.");
			logger.error("Exception object: "+e);
		}
	}

	/**
	 * AIDL/ITelephony technique for ignoring calls
	 */
	private void ignoreCallAidl() {
		try
		{
			telephonyService.silenceRinger();
			telephonyService.endCall();
		}
		catch (RemoteException e)
		{
			e.printStackTrace();
			logger.error("FATAL ERROR: call to service method endCall failed.");
			logger.error("Exception object: "+e);
		}
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();

		unregisterReceiver(PhoneState);
	}

	@Override
	protected void onStart() {
		super.onStart();
		logger.debug("starting CallPrompt");

		IntentFilter ph = new IntentFilter (TelephonyManager.ACTION_PHONE_STATE_CHANGED);

		registerReceiver(PhoneState, ph);
	}

	@Override
	protected void onStop() {
		super.onStop();

		logger.debug("verifying success");
		//We are sneaky.
		//We can relaunch if phones lagged in starting, so then tries to cancel our visible lifecycle
		if (!success) launch(getApplicationContext(),"");

		//there is a bug where if you test this too fast after going home, it blocks the activity start
		//so far it only seems to affect service and receiver based activity starting
		//We have the issue reported on the android issue tracker
		//in the log it will be orange: "activity start request from (pid) stopped."
	}

	void answer() {
		success = true;
		logger.debug(" Answer call");
		//special thanks the auto answer open source app
		//which demonstrated this answering functionality
		//Intent answer = new Intent(Intent.ACTION_MEDIA_BUTTON);
		//answer.putExtra(Intent.EXTRA_KEY_EVENT, new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_HEADSETHOOK));
		//sendOrderedBroadcast(answer, null);

		//due to inconsistency, replaced with more reliable cheat method Tedd discovered
		answerCallAidl();
		moveTaskToBack(true);
		finish();
	}

	void reject() {
		success = true;
		logger.debug(" Reject call");
		ignoreCallAidl();

		//moveTaskToBack(true);
    	EntryPoint.launch(this);
		finish();
	}

	//i think this isn't in 1.5, we're also using 2.0 service methods
	@Override
	public void onBackPressed() {
		super.onBackPressed();
		success = true;
	}

	//we don't want to exist after phones changes to active state or goes back to idle
	//we also don't want to rely on this receiver to close us after success
	BroadcastReceiver PhoneState = new BroadcastReceiver() {


		@Override
		public void onReceive(Context context, Intent intent) {
			if (!intent.getAction().equals("android.intent.action.PHONE_STATE")) return;
			String state = intent.getStringExtra(TelephonyManager.EXTRA_STATE);
			if (state.equals(TelephonyManager.EXTRA_STATE_OFFHOOK) || state.equals(TelephonyManager.EXTRA_STATE_IDLE)) {
				if (!success && !isFinishing()) {
					//no known intentional dismissal and not already finishing
					//need to finish to avoid handing out after missed calls
					logger.debug(": call start or return to idle, no user input success - closing the prompt");
					success = true;//so re-start won't fire
					finish();
				}
			}

			return;

		}};

		//let's allow the camera press to accept this call
		@Override
		public boolean dispatchKeyEvent(KeyEvent event) {
			switch (event.getKeyCode()) {
			case KeyEvent.KEYCODE_FOCUS:
				return true;
				//this event occurs - if passed on, phones retakes focus
				//so let's consume it to avoid that outcome
			case KeyEvent.KEYCODE_CAMERA:
			case KeyEvent.KEYCODE_DPAD_CENTER://sent by trackball and optical nav click
				if (getSharedPreferences("myLockphone", 0).getBoolean("cameraAccept", false))
					answer();
				return true;
			default:
				break;
			}
			return super.dispatchKeyEvent(event);
		}
		
		public static void launch(Context context, String contactPhone) {
			logger.debug("Launch CallPrompt!! ");
			Intent i = new Intent(context,CallPrompt.class);
			i.putExtra(PHONE_CONTACT , String.valueOf(contactPhone));

			i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK
					| Intent.FLAG_ACTIVITY_NO_USER_ACTION);

			context.startActivity(i);
		}
}

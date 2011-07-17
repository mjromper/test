package es.tid.ehealth.mobtel.android.app.ui.call;

import java.lang.reflect.Method;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.RemoteException;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.view.View;
import android.widget.ImageButton;
import android.widget.ImageView;

import com.android.internal.telephony.ITelephony;
import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.ehealth.mobtel.android.R;
import es.tid.ehealth.mobtel.android.app.listeners.CallStateListener;
import es.tid.ehealth.mobtel.android.common.bo.Contact;
import es.tid.ehealth.mobtel.android.common.components.AppActivity;
import es.tid.ehealth.mobtel.android.common.services.ContactService;
import es.tid.ehealth.mobtel.android.common.services.impl.ContactServiceImpl;

public class CallingContact extends AppActivity{
	private static final Logger logger = LoggerFactory.getLogger(CallingContact.class);

	private static String ID_CONTACT = "idContact";

	private static String PHONE_CONTACT = "phoneContact";

	private ImageButton hungdown;
	private ImageView callingContactImage;
	private String contactId = "";
	private String contactPhone = "";

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

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// grab an instance of telephony manager
		tm = (TelephonyManager) getSystemService(TELEPHONY_SERVICE);
		//logger.debug("Telephony Manager created in device: "+tm.getDeviceId());
		CallStateListener callStateListener = new CallStateListener(); 
		tm.listen(callStateListener, PhoneStateListener.LISTEN_CALL_STATE); 

		// connect to the underlying Android telephony system
		connectToTelephonyService();

		setContentView(R.layout.callingcontact);

		Bundle extras = getIntent().getExtras();
		contactId  = extras.getString(ID_CONTACT);
		contactPhone  = extras.getString(PHONE_CONTACT);

		logger.debug("Contact calling (id,phonenumber)-> ("+contactId+","+contactPhone+")");

		init();		 
	}

	/** From Tedd's source
	 * http://code.google.com/p/teddsdroidtools/source/browse/
	 * get an instance of ITelephony to talk handle calls with
	 */
	private void connectToTelephonyService() {
		try
		{			
			Class<?> c = Class.forName(tm.getClass().getName());
			Method m = c.getDeclaredMethod("getITelephony");
			m.setAccessible(true);
			telephonyService = (ITelephony) m.invoke(tm);
			//logger.debug("Connected to TelephonyService: "+tm.getClass().getName());

		} catch (Exception e) {
			e.printStackTrace();
			logger.error("FATAL ERROR: could not connect to telephony subsystem");
			logger.error("Exception object: "+e);
			finish();
		}
	}

	private void init() {

		contactS = new ContactServiceImpl(this);

		hungdown = (ImageButton) findViewById(R.id.hung_down_button);
		hungdown.setImageResource(R.drawable.hungdown);
		hungdown.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				reject();
			}
		});
		callingContactImage = (ImageView) findViewById(R.id.callingcontactimage);

		Contact contact = contactS.getContactByPhoneNumber(contactPhone);		
		if (contact != null){
			callingContactImage.setImageBitmap(contact.getPhotoBitmap());
		}else{
			callingContactImage.setImageResource(R.drawable.unknowncontact);
		}		

	}

	private void reject() {
		logger.debug(" Reject call");
		ignoreCallAidl();

		moveTaskToBack(true);
		finish();
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

	public static void launch(Context context, String contactId, String contactPhone){
		Intent i = new Intent(context,CallingContact.class);
		i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		i.putExtra(CallingContact.ID_CONTACT, String.valueOf(contactId));
		i.putExtra(CallingContact.PHONE_CONTACT , String.valueOf(contactPhone));
		context.startActivity(i);

	}	 

}

package es.tid.ehealth.mobtel.android.app.ui.dialog;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.ehealth.mobtel.android.common.components.AppAlertDialog;

public class MissedCallAlertDialog extends AppAlertDialog{
	
	private static final Logger logger = LoggerFactory.getLogger(MissedCallAlertDialog.class);

	@Override
    protected void onCreate(Bundle savedInstanceState) {		
		setButtonLabels("View", "Cancel");
		super.onCreate(savedInstanceState);		
	}

	@Override
	protected void doOk() {
		finish();	
		
	}

	@Override
	protected void doCancel() {
		finish();	
		
	}
	
	public static void showAlertDialog(Context context, String title, String messageOrigin) {
		logger.debug("Show SMS Dialog");
		Intent i = new Intent(context, MissedCallAlertDialog.class);
		i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		i.putExtra(AppAlertDialog.DIALOG_TYPE, AppAlertDialog.DIALOG_YES_NO_LONG_MESSAGE);
		i.putExtra(AppAlertDialog.DIALOG_TITLE, title);
		i.putExtra(AppAlertDialog.DIALOG_MESSAGE, "From "+messageOrigin);
		context.startActivity(i);
		
	}



}

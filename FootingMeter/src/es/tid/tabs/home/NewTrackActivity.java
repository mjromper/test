package es.tid.tabs.home;


import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import es.tid.R;
import es.tid.tabs.TabGroupActivity;

public class NewTrackActivity extends Activity {
	private EditText runningName;


	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.new_track_layout);

		// trackName = (Button) findViewById(R.id.newTrackTrackName);
		runningName = (EditText) findViewById(R.id.newTrackRunningName);

		final Button nextBtn = (Button) findViewById(R.id.start_btn);
		OnClickListener nextBtnListener = new OnClickListener() {
			@Override
			public void onClick(View v) {
				// elena
				// UtilsStride.trackName =
				// trackName.getSelectedItem().toString();
				UtilsFooting.runningName = runningName.getText().toString();		
				
				TabGroupActivity parentActivity = (TabGroupActivity) getParent();
				Intent intent = new Intent(parentActivity,
						RunningActivity.class);
				parentActivity.startChildActivity("RunningActivity",
						intent);			

			}
		};

		nextBtn.setOnClickListener(nextBtnListener);
	}

	


}

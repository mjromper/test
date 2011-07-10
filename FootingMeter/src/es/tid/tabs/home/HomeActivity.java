package es.tid.tabs.home;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.widget.Button;
import es.tid.R;
import es.tid.tabs.TabGroupActivity;

public class HomeActivity extends Activity {


	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.home_layout);

		final TabGroupActivity parentActivity = (TabGroupActivity) getParent();
		parentActivity.closeAllChildsExceptLastOne();

		final Button newTrackBtn = (Button) findViewById(R.id.new_track_btn);

		OnTouchListener newTrackListener = new OnTouchListener() {
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if (event.getAction() == MotionEvent.ACTION_UP) {
					Intent intent = new Intent(getParent(),
							NewTrackActivity.class);
					TabGroupActivity parentActivity = (TabGroupActivity) getParent();
					parentActivity.startChildActivity("NewTrackActivity",
							intent);
					return true;
				}
				return false;
			}
		};
		newTrackBtn.setOnTouchListener(newTrackListener);
	}

}

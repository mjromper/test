package es.tid.tabs;

import java.util.ArrayList;

import android.app.Activity;
import android.app.ActivityGroup;
import android.app.LocalActivityManager;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.Window;

public class TabGroupActivity extends ActivityGroup
{
	private ArrayList<String> mIdList;

	@Override
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		if (mIdList == null)
			mIdList = new ArrayList<String>();
	}

	public void goToFirstOne()
	{
		LocalActivityManager manager = getLocalActivityManager();
		int count = mIdList.size() - 1;
		for (int i = count; i >= 1; i--)
		{
			manager.destroyActivity(mIdList.get(i), true);
			mIdList.remove(i);
		}

		String lastId = mIdList.get(0);
		Intent lastIntent = manager.getActivity(lastId).getIntent();
		Window newWindow = manager.startActivity(lastId, lastIntent);
		setContentView(newWindow.getDecorView());
	}

	public void closeAllChildsExceptLastOne()
	{
		LocalActivityManager manager = getLocalActivityManager();
		int count = mIdList.size() - 1;
		for (int i = count; i >= 0; i--)
		{
			manager.destroyActivity(mIdList.get(i), true);
			mIdList.remove(i);
		}
	}

	/**
	 * This is called when a child activity of this one calls its finish method.
	 * This implementation calls {@link LocalActivityManager#destroyActivity} on
	 * the child activity and starts the previous activity. If the last child
	 * activity just called finish(),this activity (the parent), calls finish to
	 * finish the entire group.
	 */
	@Override
	public void finishFromChild(Activity child)
	{
		LocalActivityManager manager = getLocalActivityManager();
		int index = mIdList.size() - 1;

		if (index < 1)
		{
			finish();
			return;
		}

		manager.destroyActivity(mIdList.get(index), true);
		mIdList.remove(index);
		index--;
		String lastId = mIdList.get(index);
		Intent lastIntent = manager.getActivity(lastId).getIntent();
		Window newWindow = manager.startActivity(lastId, lastIntent);
		setContentView(newWindow.getDecorView());
	}

	/**
	 * Starts an Activity as a child Activity to this.
	 * 
	 * @param Id
	 *            Unique identifier of the activity to be started.
	 * @param intent
	 *            The Intent describing the activity to be started.
	 * @throws android.content.ActivityNotFoundException.
	 */
	
	
	public void startChildActivity(String Id, Intent intent)
	{
		intent = intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
		Window window = getLocalActivityManager().startActivity(Id, intent);

		if (window != null)
		{
			mIdList.add(Id);
			setContentView(window.getDecorView());
		}

//		View view = getLocalActivityManager().startActivity("ReferenceName",
//				new Intent(this, YourActivity.class).addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)).getDecorView();
//		this.setContentView(view);
	}

	/**
	 * The primary purpose is to prevent systems before
	 * android.os.Build.VERSION_CODES.ECLAIR from calling their default
	 * KeyEvent.KEYCODE_BACK during onKeyDown.
	 */
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event)
	{
		if (keyCode == KeyEvent.KEYCODE_BACK)
		{
			// preventing default implementation previous to
			// android.os.Build.VERSION_CODES.ECLAIR
			return true;
		}
		return super.onKeyDown(keyCode, event);
	}

	/**
	 * Overrides the default implementation for KeyEvent.KEYCODE_BACK so that
	 * all systems call onBackPressed().
	 */
	@Override
	public boolean onKeyUp(int keyCode, KeyEvent event)
	{
		if (keyCode == KeyEvent.KEYCODE_BACK)
		{
			onBackPressed();
			return true;
		}
		return super.onKeyUp(keyCode, event);
	}

	/**
	 * If a Child Activity handles KeyEvent.KEYCODE_BACK. Simply override and
	 * add this method.
	 */
	@Override
	public void onBackPressed()
	{
		int length = mIdList.size();
		if (length > 1)
		{
			Activity current = getLocalActivityManager().getActivity(mIdList.get(length - 1));
			current.finish();
		}
	}
}

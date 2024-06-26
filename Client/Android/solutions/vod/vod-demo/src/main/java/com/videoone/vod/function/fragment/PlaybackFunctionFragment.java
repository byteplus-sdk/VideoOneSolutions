package com.videoone.vod.function.fragment;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.byteplus.voddemo.R;
import com.videoone.app.protocol.IFunctionEntry;

import java.util.ArrayList;
import java.util.List;

public class PlaybackFunctionFragment extends Fragment {

    private static final String TAG = "PlaybackFunction";

    /**
     * @see com.videoone.app.protocol.FunctionVideoPlayback
     * @see com.videoone.app.protocol.FunctionPlaylist
     * @see com.videoone.app.protocol.FunctionSmartSubtitles
     * @see com.videoone.app.protocol.FunctionPreventRecording
     */
    private final String[] entryNames = new String[]{
            "com.videoone.app.protocol.FunctionVideoPlayback",
            "com.videoone.app.protocol.FunctionPreventRecording",
            "com.videoone.app.protocol.FunctionSmartSubtitles",
            "com.videoone.app.protocol.FunctionPlaylist"
    };

    private final List<IFunctionEntry> mEntries = new ArrayList<>();

    public PlaybackFunctionFragment() {
        super(R.layout.vevod_fragment_playback_function);
        for (String name : entryNames) {
            try {
                Class<?> clazz = Class.forName(name);
                IFunctionEntry entry = (IFunctionEntry) clazz.newInstance();
                mEntries.add(entry);
            } catch (ReflectiveOperationException e) {
                Log.w(TAG, "Entry not found: $entryClass");
            }
        }
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        Context context = requireContext();
        ViewGroup listview = view.findViewById(R.id.list);

        LayoutInflater inflater = LayoutInflater.from(context);

        ViewGroup categoryItems = null;

        for (IFunctionEntry info : mEntries) {
            View categoryLayout = inflater.inflate(R.layout.vevod_layout_playback_function_category, listview, false);
            categoryItems = categoryLayout.findViewById(R.id.items);
            listview.addView(categoryLayout);

            View itemView = inflater.inflate(R.layout.vevod_layout_playback_function_item,
                    categoryItems, false);
            TextView itemText = itemView.findViewById(R.id.title);
            itemText.setText(info.getTitle());
            ImageView itemImg = itemView.findViewById(R.id.icon);
            itemImg.setImageResource(info.getIcon());
            itemView.setOnClickListener(v -> {
                info.startup(context);
            });

            categoryItems.addView(itemView);
        }
    }
}

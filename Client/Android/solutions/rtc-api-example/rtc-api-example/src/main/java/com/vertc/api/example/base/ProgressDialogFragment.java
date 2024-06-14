package com.vertc.api.example.base;

import androidx.fragment.app.DialogFragment;

import com.vertc.api.example.R;

public class ProgressDialogFragment extends DialogFragment {
    public ProgressDialogFragment() {
        super(R.layout.fragment_progress_dialog);
        setStyle(STYLE_NO_TITLE, R.style.ExampleProgressDialog);
        setCancelable(false);
    }
}

// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.settingskit;

import android.app.AlertDialog;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.SwitchCompat;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;
import java.util.Objects;

public class SettingsFragment extends Fragment {

    private Adapter mAdapter;
    private List<SettingItem> mItems;

    public static final String EXTRA_SETTINGS_KEY = "EXTRA_SETTINGS_KEY";

    public static Fragment newInstance(String settingsKey) {
        Fragment fragment = new SettingsFragment();
        Bundle bundle = new Bundle();
        bundle.putString(EXTRA_SETTINGS_KEY, settingsKey);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public void onCreateOptionsMenu(@NonNull Menu menu, @NonNull MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        MenuItem menuItem = menu.add(0, 100, 0, R.string.vevod_reset);
        menuItem.setVisible(true);
        menuItem.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS);
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if (item.getItemId() == 100) {
            showResetOptionsDialog();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        final String key = requireArguments().getString("EXTRA_SETTINGS_KEY");
        mItems = Objects.requireNonNull(Settings.get(key));

        setHasOptionsMenu(true);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.vevod_settings_fragment, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        RecyclerView recyclerView = view.findViewById(R.id.recycler);
        recyclerView.setLayoutManager(new LinearLayoutManager(requireContext()));
        mAdapter = new Adapter(mItems);
        recyclerView.setAdapter(mAdapter);
    }

    @Override
    public void onResume() {
        super.onResume();
        mAdapter.notifyDataSetChanged();
    }

    private void showResetOptionsDialog() {
        new AlertDialog.Builder(requireActivity())
                .setTitle(R.string.vevod_reset_all_options)
                .setCancelable(true)
                .setPositiveButton(R.string.vevod_reset, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        resetOptions();
                    }
                })
                .setNegativeButton(R.string.vevod_cancel, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .show();
    }

    private void resetOptions() {
        for (SettingItem settingItem : mItems) {
            if (settingItem.type == SettingItem.TYPE_OPTION) {
                settingItem.option.userValues().saveValue(settingItem.option, null);
            }
        }
        mAdapter.notifyDataSetChanged();
    }

    private static class Adapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
        private List<SettingItem> mItems;

        public Adapter(List<SettingItem> items) {
            mItems = items;
        }

        @NonNull
        @Override
        public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return ItemViewHolder.create(parent, viewType);
        }

        @Override
        public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
            final SettingItem item = mItems.get(position);
            ((ItemViewHolder) holder).bind(item, position);
            holder.itemView.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    if (item.type == SettingItem.TYPE_OPTION && item.option != null) {
                        showOptionItemResetDialog(v.getContext(), item, holder);
                        return true;
                    }
                    return false;
                }
            });
        }

        private void showOptionItemResetDialog(Context context, SettingItem settingItem, RecyclerView.ViewHolder holder) {
            new AlertDialog.Builder(context)
                    .setTitle(context.getString(R.string.vevod_reset_option, context.getString(settingItem.option.title)))
                    .setCancelable(true)
                    .setPositiveButton(R.string.vevod_reset, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            settingItem.option.userValues().saveValue(settingItem.option, null);
                            notifyItemChanged(holder.getAbsoluteAdapterPosition());
                        }
                    })
                    .setNegativeButton(R.string.vevod_cancel, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            dialog.cancel();
                        }
                    })
                    .show();
        }

        @Override
        public int getItemCount() {
            return mItems.size();
        }

        @Override
        public int getItemViewType(int position) {
            SettingItem item = mItems.get(position);
            if (item.type == SettingItem.TYPE_OPTION) {
                return item.option.type;
            } else {
                return item.type;
            }
        }

        abstract static class ItemViewHolder extends RecyclerView.ViewHolder {

            public ItemViewHolder(@NonNull View itemView) {
                super(itemView);
            }

            public static RecyclerView.ViewHolder create(ViewGroup parent, int viewType) {
                switch (viewType) {
                    case SettingItem.TYPE_CATEGORY_TITLE:
                        return CategoryTitleHolder.create(parent);
                    case Option.TYPE_RATIO_BUTTON:
                        return RatioButtonViewHolder.create(parent);
                    case Option.TYPE_SELECTABLE_ITEMS:
                        return SelectableItemsViewHolder.create(parent);
                    case Option.TYPE_EDITABLE_TEXT:
                        return EditableTextViewHolder.create(parent);
                    case SettingItem.TYPE_COPYABLE_TEXT:
                        return CopyableTextViewHolder.create(parent);
                    case SettingItem.TYPE_CLICKABLE_ITEM:
                        return ClickableViewHolder.create(parent);
                    case SettingItem.TYPE_ACTION_ITEM:
                        return ClickActionItemHolder.create(parent);
                    default:
                        throw new IllegalArgumentException("Unsupported viewType " + viewType);
                }
            }

            abstract void bind(SettingItem item, int position);

            static void bindText(TextView textView, SettingItem item) {
                if (item.getter != null) {
                    if (item.getter.directGetter == null) {
                        item.getter.asyncGetter.get(textView::setText);
                        textView.setText(null);
                    } else {
                        textView.setText((String) item.getter.directGetter.get());
                    }
                } else {
                    textView.setText(null);
                }
            }
        }

        static class CategoryTitleHolder extends ItemViewHolder {
            private final TextView categoryTitle;

            public CategoryTitleHolder(@NonNull View itemView) {
                super(itemView);
                categoryTitle = (TextView) itemView;
            }

            @Override
            void bind(SettingItem item, int position) {
                categoryTitle.setText(item.title);
                if (position == 0) {
                    ((ViewGroup.MarginLayoutParams) categoryTitle.getLayoutParams()).topMargin = (int) Utils.dip2Px(itemView.getContext(), 10);
                } else {
                    ((ViewGroup.MarginLayoutParams) categoryTitle.getLayoutParams()).topMargin = (int) Utils.dip2Px(itemView.getContext(), 24);
                }
            }

            static CategoryTitleHolder create(ViewGroup parent) {
                return new CategoryTitleHolder(LayoutInflater.from(parent.getContext())
                        .inflate(R.layout.vevod_settings_item_category_title, parent, false));
            }
        }

        static class RatioButtonViewHolder extends ItemViewHolder {
            private final SwitchCompat switchView;

            public RatioButtonViewHolder(@NonNull View itemView) {
                super(itemView);
                switchView = itemView.findViewById(R.id.switchView);
            }

            @Override
            void bind(SettingItem item, int position) {
                Boolean value = item.option.value(Boolean.class);
                switchView.setOnCheckedChangeListener(null);
                if (value == null) {
                    switchView.setChecked(false);
                    switchView.setEnabled(false);
                } else {
                    switchView.setChecked(value);
                    switchView.setEnabled(true);
                }
                switchView.setOnCheckedChangeListener((buttonView, isChecked) -> {
                    item.option.userValues().saveValue(item.option, isChecked);
                });

                switchView.setText(item.option.title);
            }

            static RatioButtonViewHolder create(ViewGroup parent) {
                return new RatioButtonViewHolder(LayoutInflater.from(parent.getContext())
                        .inflate(R.layout.vevod_settings_item_ratio_button, parent, false));
            }
        }

        static class SelectableItemsViewHolder extends ItemViewHolder {
            private final TextView titleView;
            private final TextView valueView;

            public SelectableItemsViewHolder(@NonNull View itemView) {
                super(itemView);
                titleView = itemView.findViewById(R.id.itemTitle);
                valueView = itemView.findViewById(R.id.valueView);
            }

            @Override
            void bind(SettingItem item, int position) {
                titleView.setText(item.option.title);
                valueView.setText(item.mapper.toString(item.option.value()));
                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        showSelectableItemsDialog(v.getContext(), item, SelectableItemsViewHolder.this);
                    }
                });
            }

            public static void showSelectableItemsDialog(Context context, SettingItem settingItem, RecyclerView.ViewHolder holder) {
                Option option = settingItem.option;
                int index = option.candidates.indexOf(option.value());
                String[] items = new String[option.candidates.size()];
                for (int i = 0; i < items.length; i++) {
                    items[i] = settingItem.mapper.toString(option.candidates.get(i));
                }
                new AlertDialog.Builder(context)
                        .setTitle(option.title)
                        .setCancelable(true)
                        .setSingleChoiceItems(items, index, new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                Object o = option.candidates.get(which);
                                option.userValues().saveValue(option, o);
                                RecyclerView.Adapter<?> adapter = holder.getBindingAdapter();
                                if (adapter != null) {
                                    adapter.notifyItemChanged(holder.getAbsoluteAdapterPosition());
                                }
                                dialog.cancel();
                            }
                        })
                        .show();
            }

            static SelectableItemsViewHolder create(ViewGroup parent) {
                return new SelectableItemsViewHolder(LayoutInflater.from(parent.getContext())
                        .inflate(R.layout.vevod_settings_item_selectable_items, parent, false));
            }
        }

        static class EditableTextViewHolder extends ItemViewHolder {
            private final TextView titleView;
            private final TextView valueView;

            public EditableTextViewHolder(@NonNull View itemView) {
                super(itemView);
                titleView = itemView.findViewById(R.id.itemTitle);
                valueView = itemView.findViewById(R.id.valueView);
            }

            @Override
            void bind(SettingItem item, int position) {
                titleView.setText(item.option.title);
                valueView.setText(item.mapper.toString(item.option.value()));
                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        showEditableDialog(v.getContext(), item, EditableTextViewHolder.this);
                    }
                });
            }

            public static void showEditableDialog(Context context, SettingItem item, RecyclerView.ViewHolder holder) {
                View content = LayoutInflater.from(context).inflate(R.layout.vevod_settings_item_editable_dialog, null);

                EditText editText = content.findViewById(R.id.editor);
                editText.setText(item.mapper.toString(item.option.value()));

                new AlertDialog.Builder(context)
                        .setCancelable(true)
                        .setTitle(context.getString(R.string.vevod_edit_option, context.getString(item.option.title)))
                        .setView(content)
                        .setPositiveButton(R.string.vevod_confirm, (dialog, which) -> {
                            Editable value = editText.getText();
                            String newValue = value.toString().trim();
                            if (!TextUtils.isEmpty(newValue)) {
                                item.option.userValues().saveValue(item.option, newValue);
                                RecyclerView.Adapter<?> adapter = holder.getBindingAdapter();
                                if (adapter != null) {
                                    adapter.notifyItemChanged(holder.getAbsoluteAdapterPosition());
                                }
                            }
                            dialog.cancel();
                        })
                        .setNegativeButton(R.string.vevod_cancel, (dialog, which) -> dialog.cancel())
                        .show();
            }

            static EditableTextViewHolder create(ViewGroup parent) {
                return new EditableTextViewHolder(LayoutInflater.from(parent.getContext())
                        .inflate(R.layout.vevod_settings_item_selectable_items, parent, false));
            }
        }

        static class ClickActionItemHolder extends ItemViewHolder {
            private final TextView titleView;

            public ClickActionItemHolder(@NonNull View itemView) {
                super(itemView);
                titleView = itemView.findViewById(R.id.itemTitle);
            }

            @Override
            void bind(SettingItem item, int position) {
                titleView.setText(item.title);
                if (item.listener != null) {
                    itemView.setOnClickListener(v -> {
                        item.listener.onEvent(SettingItem.OnEventListener.EVENT_TYPE_CLICK,
                                v.getContext(), item, ClickActionItemHolder.this);
                    });
                }
            }

            static ClickActionItemHolder create(ViewGroup parent) {
                return new ClickActionItemHolder(LayoutInflater.from(parent.getContext())
                        .inflate(R.layout.vevod_settings_item_click_to_next, parent, false));
            }
        }

        static class CopyableTextViewHolder extends ItemViewHolder {

            private final TextView titleView;
            private final TextView textView;
            private final TextView copyView;

            public CopyableTextViewHolder(@NonNull View itemView) {
                super(itemView);
                titleView = itemView.findViewById(R.id.itemTitle);
                textView = itemView.findViewById(R.id.text);
                copyView = itemView.findViewById(R.id.copy);
            }

            @Override
            void bind(SettingItem item, int position) {
                titleView.setText(item.title);
                bindText(textView, item);
                copyView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        ClipboardManager clipboardManager = (ClipboardManager) v.getContext().getSystemService(Context.CLIPBOARD_SERVICE);
                        CharSequence c = textView.getText();
                        if (TextUtils.isEmpty(c)) {
                            return;
                        }
                        ClipData clipData = ClipData.newPlainText(v.getContext().getPackageName(), c);
                        clipboardManager.setPrimaryClip(clipData);

                        CenteredToast.show(v.getContext(), R.string.vevod_text_copied);
                    }
                });
            }

            static CopyableTextViewHolder create(ViewGroup parent) {
                return new CopyableTextViewHolder(LayoutInflater.from(parent.getContext())
                        .inflate(R.layout.vevod_settings_item_copyable_text, parent, false));
            }
        }

        static class ClickableViewHolder extends ItemViewHolder {
            private final TextView titleView;
            private final TextView valueView;

            public ClickableViewHolder(@NonNull View itemView) {
                super(itemView);
                titleView = itemView.findViewById(R.id.itemTitle);
                valueView = itemView.findViewById(R.id.valueView);
            }

            @Override
            void bind(SettingItem item, int position) {
                titleView.setText(item.title);
                bindText(valueView, item);
                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        item.listener.onEvent(SettingItem.OnEventListener.EVENT_TYPE_CLICK, v.getContext(), item, ClickableViewHolder.this);
                    }
                });
            }

            static ClickableViewHolder create(ViewGroup parent) {
                return new ClickableViewHolder(LayoutInflater.from(parent.getContext())
                        .inflate(R.layout.vevod_settings_item_clickable_item, parent, false));
            }
        }
    }
}

-- Visual effects, all off for a plain baseline.
-- Turn them on one at a time and check htop over ssh after each change.
return {
   background_image = false, -- backdrop image behind the text (Alt+B still toggles it)
   fancy_tab_bar = false, -- native-looking tab bar with close buttons instead of the plain one
   scroll_bar = false, -- scroll bar on the right
   cursor_blink = false, -- blinking cursor with ease in/out animation
   visual_bell = false, -- fade the cursor color on bell
   lcd_font_smoothing = false, -- ClearType-like subpixel rendering instead of grayscale
}

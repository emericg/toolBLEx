Internationalization quick guide
--------------------------------

You can work on translations using one of two ways:
- [Using GitHub](https://github.com/firstcontributions/first-contributions/blob/master/README.md) by forking, branching, translating and creating a pull request.
- Directly, by downloading, translating and emailing the translation files back. It's a way more straightforward workflow, don't bother with GitHub if you don't know how to use it.

##### Step 1: Add the language to the project (if it's a new language)

Edit the Qt project file (_CMakeLists.txt_) and add a new language file entry to the I18N_TRANSLATED_LANGUAGES section.  
You'll need to use an [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) two letter code (ex: _i18n/toolBLEx_fr.ts_).  

> qt_standard_project_setup(I18N_TRANSLATED_LANGUAGES de fr xx)

##### Step 2: Create / update the language file

To create (or update) the actual translation file, from the project root directory, run the following command:

```
cmake --build build/ --target lupdate
```

This will scrape the source code and add/update the strings that need to be translated into the language files.  
If you are not able to run that command, you can simply open a GitHub issue and ask me for a new translation file in the langugage file you want.  

##### Step 3: Translating

Translate by editing the .ts file using Qt Linguist.

- Remember to match upper/lower case letters, punctuation and trailing spaces!
- You don't have to translate everything, missing strings will fall back to English.
- If you're not sure about a word or sentence, leave the "unfinished" tag, so other people can have a second look at it.

> Qt Linguist manual: https://doc.qt.io/qt-6/linguist-translators.html

> Qt Linguist standalone downloads: https://github.com/thurask/Qt-Linguist/releases

> Qt Linguist standalone downloads: https://github.com/lelegard/qtlinguist-installers/releases

##### Step 4: Publish it!

Send the file(s) back to the project, using email or a GitHub pull request.  
If you want to be credited in the application (and in this file) please be sure to mention it, and provide a name/pseudo, and wished an email/GitHub page.  
It's useful in case a person wants to contact you about the translation, or if you want to be contacted when a new version of the project will be released and a translation update is needed.


Special thanks
--------------

**French**
- Emeric Grange <emeric.grange@gmail.com>

**Russian**
- Andrey Alypov

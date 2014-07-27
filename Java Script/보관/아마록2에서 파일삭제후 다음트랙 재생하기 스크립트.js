Importer.loadQtBinding("qt.core");

function removeCurrent() {
	//var target = Amarok.Engine.currentTrack().path;
	var target = new QFile(Amarok.Engine.currentTrack().path);
	if( Amarok.Playlist.totalTrackCount() -1 > Amarok.Playlist.activeIndex() ){
		Amarok.Engine.Next();
	} else {
		Amarok.Engine.Pause();
		Amarok.Engine.Stop();
	}
	//var rm = new QProcess()
	//rm.start("kioclient", ["move", target, "trash:/"], QIODevice.ReadOnly);
	//Amarok.alert( Amarok.Engine.currentTrack().path );
	//rm.waitForFinished();
	//rm.close();
	target.remove();
}


// Add Tools menu options
Amarok.Window.addToolsMenu("REMOVE_CURRENT", "삭제하고 다음곡으로", "news-unsubscribe");
// Bind Menu entries to functions
Amarok.Window.ToolsMenu.REMOVE_CURRENT['triggered()'].connect(removeCurrent);


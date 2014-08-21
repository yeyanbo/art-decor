			function toggleMap (toggled, toggler, assetsdir) {
                if (document.getElementById) {
                    var togglerObj = document.getElementById(toggler);
                    var togglerStyle = togglerObj.style;
					var togglerimgsrc = togglerObj.getElementsByTagName("img")[0].src;
                    if (togglerimgsrc.indexOf("folderopen")>0){
                        toggle("fold","tr",toggled);
                        togglerObj.getElementsByTagName("img")[0].src = assetsdir + "folder.png";
                    } else {
                        toggle("unfold","tr",toggled);
                        togglerObj.getElementsByTagName("img")[0].src = assetsdir + "folderopen.png";
                    }
                    return false;
                } else {
                return true;
                }
            }
            
            function toggleZoom (toggled, toggler, assetsdir) {
                if (document.getElementById) {
                    var currentStyle = document.getElementById(toggled).style;
                    var togglerStyle = document.getElementById(toggler).style;
                    if (currentStyle.display == "block"){
                        currentStyle.display = "none";
                        togglerStyle.backgroundImage = "url(" + assetsdir + "zoomin.png)";
                    } else {
                        currentStyle.display = "block";
                        togglerStyle.backgroundImage = "url(" + assetsdir + "zoomout.png)";
                    }
                    return false;
                } else {
                return true;
                }
            }
            
            function toggleZoomImg (el,zoomType, assetsdir) {
                if (document.getElementById) {
                    if (zoomType == "zoomin"){
                        el.style.backgroundImage = "url(" + assetsdir + "zoomin.png)";
                        /*el.setAttribute('onclick','toggleZoomImg(this,\'zoomout\',\''+assetsdir+'\');');*/
                        // below is less destructive for anything else in onclick
                        el.setAttribute('onclick', el.getAttribute('onclick').replace('zoomin','zoomout'));
                    } else {
                        el.style.backgroundImage = "url(" + assetsdir + "zoomout.png)";
                        /*el.setAttribute('onclick','toggleZoomImg(this,\'zoomin\',\''+assetsdir+'\');');*/
                        // below is less destructive for anything else in onclick
                        el.setAttribute('onclick', el.getAttribute('onclick').replace('zoomout','zoomin'));
                    }
                    return false;
                } else {
                return true;
                }
            }
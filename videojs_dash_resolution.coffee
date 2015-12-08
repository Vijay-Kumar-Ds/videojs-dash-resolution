((window, videojs) ->
  defaults =
    option: true

  dashResolution = (options) ->
    # settings = videojs.util.mergeOptions(defaults, options)
    player = this
    dashMediaPlayer = null

    Button = videojs.getComponent('MenuButton')
    MenuItem = videojs.getComponent('MenuItem')
    Menu = videojs.getComponent('Menu')


    player.resolution_ = 'auto'
    player.playbackResolution = (resolution) ->
      if resolution == undefined
        return player.resolution_

      newResolution = resolution
      # Magic to change the resolution
      if dashMediaPlayer
        if resolution != 'auto'
          list = dashMediaPlayer.getBitrateInfoListFor('video')
          selectIndex = 0

          for info, index in list
            if info.bitrate.toString() == resolution
              selectIndex = index

          dashMediaPlayer.setQualityFor('video', selectIndex)
          dashMediaPlayer.setAutoSwitchQuality(false)
        else
          dashMediaPlayer.setAutoSwitchQuality(true)

      player.resolution_ = newResolution
      player.trigger('resolutionchange')
      return newResolution


    PlaybackResolutionMenuItem = videojs.extend(MenuItem,
      constructor: (player, options) ->
        this.label = options['resolution']
        this.resolution = options['resolution']
        options['label'] = this.label
        options['selected'] = this.label == 'auto'

        MenuItem.call(this, player, options)
        this.on(player, 'resolutionchange', this.update);


      handleClick: () ->
        MenuItem.prototype.handleClick.call(this)
        this.player().playbackResolution(this.resolution)

      update: () ->
        console.log dashMediaPlayer.getQualityFor('video')
        this.selected(this.player().resolution_ == this.resolution);
    )


    PlaybackResolutionButton = videojs.extend(Button,
      constructor: (player, options) ->
        Button.call(this, player, options)
        # listen to the resolutionchange event and update label text?

      createEl: () ->
        el = Button.prototype.createEl.call(this)

        label = document.createElement('div')
        label.innerHTML = 'HD'
        label.className = 'vjs-playback-resolution'

        el.appendChild(label)
        return el

      buildCSSClass: () ->
        return 'vjs-playback-resolution-button ' + Button.prototype.buildCSSClass.call(this)

      createMenu: () ->
        menu = new Menu(player)
        resolutions = dashMediaPlayer.getBitrateInfoListFor('video').map (info, index) ->
          console.log info
          return info.bitrate.toString()

        resolutions.push('auto')

        for res, i in resolutions
          item = new PlaybackResolutionMenuItem(player, {'resolution': res })
          menu.addChild item

        return menu
    )

    # MyButton.prototype.controlText_ = 'Playback Resolution'

    # nearest callback
    # not work for dash.min.js
    # player.one('ready', () ->
    #   dashMediaPlayer = player.tech_.sourceHandler_.mediaPlayer_
    #   logHandler = (e) ->
    #     if e.message.indexOf('[video] stop') >= 0
    #       resBtn = new PlaybackResolutionButton(player, {})
    #       player.controlBar.addChild(resBtn)
    #       dashMediaPlayer.removeEventListener('log', logHandler)
    #
    #   dashMediaPlayer.addEventListener('log', logHandler)
    # )

    # later callback
    # maybe not working everytime
    player.one('loadedmetadata', () ->
      dashMediaPlayer = player.tech_.sourceHandler_.mediaPlayer_
      resBtn = new PlaybackResolutionButton(player, {})
      player.controlBar.addChild(resBtn)
    )



  videojs.plugin('dashResolution', dashResolution)

)(window, window.videojs)

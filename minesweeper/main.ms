#########################
#                       #
# THIS IS A MASTER FILE #
#  ~/minecraft/master   #
#                       #
#########################

## @RobotoRaccoon

include('includes.library/includes.ms');
include('includes.library/commands.ms');

bind('player_interact', null, null, @event) {
    @player = @event['player'];
    _MS_assertWorld(@player);
    _MS_assertRegion(ploc(@player), 'mine-whole');

    if (!_MS_isPlaying(@player)) {
        die();
    }

    @validBlock = array_contains(array('SNOW_BLOCK', 'FLOWER_POT'), @event['block']);
    if (@event['action'] == 'left_click_block' && !@validBlock) {
        cancel();
        _MS_antiBreak(@player);
    }
    else if (@event['action'] == 'right_click_block') {
        cancel();
        _MS_rightClick(@event);
    }
}

bind('block_break', null, null, @event) {
    @player = @event['player'];
    @loc = @event['location']
    _MS_assertWorld(@player);
    _MS_assertRegion(@loc, 'mine-snow');

    if (!_MS_isPlaying(@player)) {
        cancel();
        _error('You are not currently playing.');
    }

    @block = @event['block'];
    @validBlock = array_contains(array('SNOW_BLOCK', 'FLOWER_POT'), @block);
    if (!@validBlock) {
        cancel();
        die();
    }

    if (@block != 'SNOW_BLOCK') {
        die();
    }

    @x = integer(@loc['x']);
    @y = integer(@loc['y']);
    @z = integer(@loc['z']);

    @arena = _MS_getArena(@player);
    @info = _MS_getInfo(@arena);
    @field = @info['field'];
    @pos = _MS_grid_getpos(@info, @x, @z);
    @xpos = @pos[0];
    @zpos = @pos[1];

    ## If this is the first break
    if (@info['time'] == null) {
        @info = _MS_shuffleField(@info, @xpos, @zpos);

        ## Colour the rest of the field
        _MS_colourField(@info, @xpos, @zpos);

        @info['time'] = time(); ## Start time now
        _MS_storeInfo(@info);
    }

    if (_MS_isMine(@info, @xpos, @zpos)) {
        cancel();
        _MS_explode(@arena, @info, @x, @y, @z);
    } else {
        #_MS_setBlock(@x, @y, @z, 'AIR');
        _MS_snowBroken(@arena, @info, @x, @y, @z);
    }
}

bind('block_place', null, null, @event) {
    @player = @event['player'];
    @loc = @event['location'];
    _MS_assertWorld(@player);
    _MS_assertRegion(@loc, 'mine-snow');

    if (!_MS_isPlaying(@player)) {
        cancel();
        _error('You are not currently playing.');
    }

    @cy = _MS_corner(_MS_getArena(@player))[1];
    @block = @event['block'];
    @against = @event['against'];
    if (@loc['y'] != @cy + 2 || @block != 'FLOWER_POT' || @against != 'SNOW_BLOCK') {
        cancel();
        _error('You can only place flower pots on snow.')
    }
}

###                         ###
### Shouldn't need to touch ###
###                         ###

bind('inventory_click', null, null, @event) {
    @player = @event['player'];
    _MS_assertWorld(@player);
    _MS_assertRegion(ploc(@player), 'mine-whole');

    if (_MS_isPlaying(@player)) {
        cancel();
    }
}

bind('item_held', null, null, @event) {
    @player = @event['player'];
    _MS_assertWorld(@player);
    _MS_assertRegion(ploc(@player), 'mine-whole');

    ## Only allow first two slots to be selected
    if (_MS_isPlaying(@player) && @event['to'] > 1) {
        @from = @event['from'];
        if (@from > 1) {
            @from = 0;
        }
        modify_event('to', @from);
    }
}

bind('player_teleport', null, null, @event) {
    @player = @event['player'];
    _MS_assertWorld(@player);
    _MS_assertRegion(ploc(@player), 'mine-whole');

    if (_MS_isPlaying(@player)) {
        cancel();
        _error('You cannot teleport out of minesweeper. Blow yourself up or /mines quit');
    }
}

bind('player_quit', null, null, @event) {
    if (_MS_isPlaying(@event['player'])) {
        @arena = _MS_getArena(@event['player']);
        _MS_clear_values(@arena);
    }
}

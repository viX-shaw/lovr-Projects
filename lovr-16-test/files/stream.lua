local ffi = require('ffi')
local vlc = ffi.load('libvlc')

ffi.cdef[[
    int printf (const char *template, ...);
    typedef struct libvlc_instance_t libvlc_instance_t;
    typedef int64_t libvlc_time_t;
    libvlc_instance_t * libvlc_new( int argc , const char *const *argv );
    void libvlc_release( libvlc_instance_t *p_instance );
    typedef struct libvlc_media_t libvlc_media_t;
    typedef struct libvlc_media_player_t libvlc_media_player_t;
    libvlc_media_t *libvlc_media_new_location(
                                    libvlc_instance_t *p_instance,
                                    const char *psz_mrl );
    libvlc_media_t *libvlc_media_new_path(
                                    libvlc_instance_t *p_instance,
                                    const char *path );
    libvlc_media_player_t * libvlc_media_player_new( libvlc_instance_t *p_libvlc_instance );
    void libvlc_media_player_release( libvlc_media_player_t *p_mi );
    void libvlc_media_player_set_media( libvlc_media_player_t *p_mi,
                                                    libvlc_media_t *p_md );

    void libvlc_media_player_pause(libvlc_media_player_t * p_mi);
    void libvlc_media_player_stop ( libvlc_media_player_t *p_mi );
    int libvlc_media_player_stop_async (libvlc_media_player_t *p_mi);
    int libvlc_media_player_play ( libvlc_media_player_t *p_mi );
    void libvlc_media_player_release( libvlc_media_player_t *p_mi );
    void libvlc_media_release(libvlc_media_t *p_md);

    typedef void *(*libvlc_video_lock_cb)(void *opaque, void **planes);
    typedef void (*libvlc_video_unlock_cb)(void *opaque, void *picture, void *const *planes);
    typedef void (*libvlc_video_display_cb)(void *opaque, void *picture);

    void libvlc_video_set_callbacks( libvlc_media_player_t *mp, libvlc_video_lock_cb lock, libvlc_video_unlock_cb unlock, libvlc_video_display_cb display, void *opaque );
    void libvlc_video_set_format( libvlc_media_player_t *mp, const char *chroma, unsigned width, unsigned height, unsigned pitch );

    char * libvlc_media_get_mrl	(libvlc_media_t * p_md);
    const char * libvlc_errmsg(void);

    typedef unsigned(* libvlc_video_format_cb) (void **opaque, char *chroma, unsigned *width, unsigned *height, unsigned *pitches, unsigned *lines);
    typedef void(* libvlc_video_cleanup_cb) (void *opaque);
    void libvlc_video_set_format_callbacks( libvlc_media_player_t * mp, libvlc_video_format_cb 	setup, libvlc_video_cleanup_cb cleanup );

    
    typedef struct libvlc_event_manager_t libvlc_event_manager_t;
    typedef int libvlc_event_type_t;
    typedef struct libvlc_event_t libvlc_event_t;
    typedef void(* libvlc_callback_t) (const struct libvlc_event_t *p_event, void *p_data);

    libvlc_event_manager_t * libvlc_media_player_event_manager(libvlc_media_player_t *p_mi);
    int libvlc_event_attach (libvlc_event_manager_t * p_event_manager,
                             libvlc_event_type_t i_event_type,
                             libvlc_callback_t f_callback,
                             void * user_data);	
    enum libvlc_event_e {
        /* Append new event types at the end of a category.
            * Do not remove, insert or re-order any entry.
            */
    
        /**
            * Metadata of a \link #libvlc_media_t media item\endlink changed
            */
        libvlc_MediaMetaChanged=0,
        /**
            * Subitem was added to a \link #libvlc_media_t media item\endlink
            * \see libvlc_media_subitems()
            */
        libvlc_MediaSubItemAdded,
        /**
            * Duration of a \link #libvlc_media_t media item\endlink changed
            * \see libvlc_media_get_duration()
            */
        libvlc_MediaDurationChanged,
        /**
            * Parsing state of a \link #libvlc_media_t media item\endlink changed
            * \see libvlc_media_parse_request(),
            *      libvlc_media_get_parsed_status(),
            *      libvlc_media_parse_stop()
            */
        libvlc_MediaParsedChanged,
    
        /* Removed: libvlc_MediaFreed, */
        /* Removed: libvlc_MediaStateChanged */
    
        /**
            * Subitem tree was added to a \link #libvlc_media_t media item\endlink
            */
        libvlc_MediaSubItemTreeAdded = libvlc_MediaParsedChanged + 3,
        /**
            * A thumbnail generation for this \link #libvlc_media_t media \endlink completed.
            * \see libvlc_media_thumbnail_request_by_time()
            * \see libvlc_media_thumbnail_request_by_pos()
            */
        libvlc_MediaThumbnailGenerated,
        /**
            * One or more embedded thumbnails were found during the media preparsing
            * The user can hold these picture(s) using libvlc_picture_retain if they
            * wish to use them
            */
        libvlc_MediaAttachedThumbnailsFound,
    
        libvlc_MediaPlayerMediaChanged=0x100,
        libvlc_MediaPlayerNothingSpecial,
        libvlc_MediaPlayerOpening,
        libvlc_MediaPlayerBuffering,
        libvlc_MediaPlayerPlaying,
        libvlc_MediaPlayerPaused,
        libvlc_MediaPlayerStopped,
        libvlc_MediaPlayerForward,
        libvlc_MediaPlayerBackward,
        libvlc_MediaPlayerStopping,
        libvlc_MediaPlayerEncounteredError,
        libvlc_MediaPlayerTimeChanged,
        libvlc_MediaPlayerPositionChanged,
        libvlc_MediaPlayerSeekableChanged,
        libvlc_MediaPlayerPausableChanged,
        /* libvlc_MediaPlayerTitleChanged, */
        libvlc_MediaPlayerSnapshotTaken = libvlc_MediaPlayerPausableChanged + 2,
        libvlc_MediaPlayerLengthChanged,
        libvlc_MediaPlayerVout,
    
        /* libvlc_MediaPlayerScrambledChanged, use libvlc_MediaPlayerProgramUpdated */
    
        /** A track was added, cf. media_player_es_changed in \ref libvlc_event_t.u
            * to get the id of the new track. */
        libvlc_MediaPlayerESAdded = libvlc_MediaPlayerVout + 2,
        /** A track was removed, cf. media_player_es_changed in \ref
            * libvlc_event_t.u to get the id of the removed track. */
        libvlc_MediaPlayerESDeleted,
        /** Tracks were selected or unselected, cf.
            * media_player_es_selection_changed in \ref libvlc_event_t.u to get the
            * unselected and/or the selected track ids. */
        libvlc_MediaPlayerESSelected,
        libvlc_MediaPlayerCorked,
        libvlc_MediaPlayerUncorked,
        libvlc_MediaPlayerMuted,
        libvlc_MediaPlayerUnmuted,
        libvlc_MediaPlayerAudioVolume,
        libvlc_MediaPlayerAudioDevice,
        /** A track was updated, cf. media_player_es_changed in \ref
            * libvlc_event_t.u to get the id of the updated track. */
        libvlc_MediaPlayerESUpdated,
        libvlc_MediaPlayerProgramAdded,
        libvlc_MediaPlayerProgramDeleted,
        libvlc_MediaPlayerProgramSelected,
        libvlc_MediaPlayerProgramUpdated,
        /**
            * The title list changed, call
            * libvlc_media_player_get_full_title_descriptions() to get the new list.
            */
        libvlc_MediaPlayerTitleListChanged,
        /**
            * The title selection changed, cf media_player_title_selection_changed in
            * \ref libvlc_event_t.u
            */
        libvlc_MediaPlayerTitleSelectionChanged,
        libvlc_MediaPlayerChapterChanged,
        libvlc_MediaPlayerRecordChanged,
    
        /**
            * A \link #libvlc_media_t media item\endlink was added to a
            * \link #libvlc_media_list_t media list\endlink.
            */
        libvlc_MediaListItemAdded=0x200,
        /**
            * A \link #libvlc_media_t media item\endlink is about to get
            * added to a \link #libvlc_media_list_t media list\endlink.
            */
        libvlc_MediaListWillAddItem,
        /**
            * A \link #libvlc_media_t media item\endlink was deleted from
            * a \link #libvlc_media_list_t media list\endlink.
            */
        libvlc_MediaListItemDeleted,
        /**
            * A \link #libvlc_media_t media item\endlink is about to get
            * deleted from a \link #libvlc_media_list_t media list\endlink.
            */
        libvlc_MediaListWillDeleteItem,
        /**
            * A \link #libvlc_media_list_t media list\endlink has reached the
            * end.
            * All \link #libvlc_media_t items\endlink were either added (in
            * case of a \ref libvlc_media_discoverer_t) or parsed (preparser).
            */
        libvlc_MediaListEndReached
    };
]]

return vlc


-- #include <vlc/vlc.h>

-- struct ctx
-- {
--     SDL_Surface *surf;
--     SDL_mutex *mutex;
-- };

-- static void *lock(void *data, void **p_pixels)
-- {
--     struct ctx *ctx = data;

--     SDL_LockMutex(ctx->mutex);
--     SDL_LockSurface(ctx->surf);
--     *p_pixels = ctx->surf->pixels; /*pixels represent the correct multidimenisial array to hold the data*/
--     return NULL; /* picture identifier, not needed here */
-- }

-- static void unlock(void *data, void *id, void *const *p_pixels)
-- {
--     struct ctx *ctx = data;

--     /* VLC just rendered the video, but we can also render stuff */
--     uint16_t *pixels = *p_pixels;
--     int x, y;

--     for(y = 10; y < 40; y++)
--         for(x = 10; x < 40; x++)
--             if(x < 13 || y < 13 || x > 36 || y > 36)
--                 pixels[y * VIDEOWIDTH + x] = 0xffff;
--             else
--                 pixels[y * VIDEOWIDTH + x] = 0x0;

--     SDL_UnlockSurface(ctx->surf);
--     SDL_UnlockMutex(ctx->mutex);

--     assert(id == NULL); /* picture identifier, not needed here */
-- }

-- static void display(void *data, void *id)
-- {
--     /* VLC wants to display the video */
--     (void) data;
--     assert(id == NULL);
-- }

-- int main(int argc, char *argv[])
-- {
--     libvlc_instance_t *libvlc;
--     libvlc_media_t *m;
--     libvlc_media_player_t *mp;
--     char const *vlc_argv[] =
--     {
--         "--no-audio", /* skip any audio track */
--         "--no-xlib", /* tell VLC to not use Xlib */
--     };
--     int vlc_argc = sizeof(vlc_argv) / sizeof(*vlc_argv);

--     SDL_Surface *screen, *empty;
--     SDL_Event event;
--     SDL_Rect rect;
--     int done = 0, action = 0, pause = 0, n = 0;

--     struct ctx ctx;

--     if(argc < 2)
--     {
--         printf("Usage: %s <filename>\n", argv[0]);
--         return EXIT_FAILURE;
--     }

--     /*
--      *  Initialise libSDL
--      */
--     if(SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTTHREAD) == -1)
--     {
--         printf("cannot initialize SDL\n");
--         return EXIT_FAILURE;
--     }

--     empty = SDL_CreateRGBSurface(SDL_SWSURFACE, VIDEOWIDTH, VIDEOHEIGHT,
--                                  32, 0, 0, 0, 0);
--     ctx.surf = SDL_CreateRGBSurface(SDL_SWSURFACE, VIDEOWIDTH, VIDEOHEIGHT,
--                                     16, 0x001f, 0x07e0, 0xf800, 0);

--     ctx.mutex = SDL_CreateMutex();

--     int options = SDL_ANYFORMAT | SDL_HWSURFACE | SDL_DOUBLEBUF;

--     screen = SDL_SetVideoMode(WIDTH, HEIGHT, 0, options);
--     if(!screen)
--     {
--         printf("cannot set video mode\n");
--         return EXIT_FAILURE;
--     }

--     /*
--      *  Initialise libVLC
--      */
--     libvlc = libvlc_new(vlc_argc, vlc_argv);
--     m = libvlc_media_new_path(libvlc, argv[1]);
--     mp = libvlc_media_player_new_from_media(m);
--     libvlc_media_release(m);

--     libvlc_video_set_callbacks(mp, lock, unlock, display, &ctx);
--     libvlc_video_set_format(mp, "RV16", VIDEOWIDTH, VIDEOHEIGHT, VIDEOWIDTH*2);
--     libvlc_media_player_play(mp);

--     /*
--      *  Main loop
--      */
--     rect.w = 0;
--     rect.h = 0;

--     while(!done)
--     { 
--         action = 0;

--         /* Keys: enter (fullscreen), space (pause), escape (quit) */
--         while( SDL_PollEvent( &event ) ) 
--         { 
--             switch(event.type)
--             {
--             case SDL_QUIT:
--                 done = 1;
--                 break;
--             case SDL_KEYDOWN:
--                 action = event.key.keysym.sym;
--                 break;
--             }
--         }

--         switch(action)
--         {
--         case SDLK_ESCAPE:
--             done = 1;
--             break;
--         case SDLK_RETURN:
--             options ^= SDL_FULLSCREEN;
--             screen = SDL_SetVideoMode(WIDTH, HEIGHT, 0, options);
--             break;
--         case ' ':
--             pause = !pause;
--             break;
--         }

--         rect.x = (int)((1. + .5 * sin(0.03 * n)) * (WIDTH - VIDEOWIDTH) / 2);
--         rect.y = (int)((1. + .5 * cos(0.03 * n)) * (HEIGHT - VIDEOHEIGHT) / 2);

--         if(!pause)
--             n++;

--         /* Blitting the surface does not prevent it from being locked and
--          * written to by another thread, so we use this additional mutex. */
--         SDL_LockMutex(ctx.mutex);
--         SDL_BlitSurface(ctx.surf, NULL, screen, &rect);
--         SDL_UnlockMutex(ctx.mutex);

--         SDL_Flip(screen);
--         SDL_Delay(10);

--         SDL_BlitSurface(empty, NULL, screen, &rect);
--     }

--     /*
--      * Stop stream and clean up libVLC
--      */
--     libvlc_media_player_stop(mp);
--     libvlc_media_player_release(mp);
--     libvlc_release(libvlc);

--     /*
--      * Close window and clean up libSDL
--      */
--     SDL_DestroyMutex(ctx.mutex);
--     SDL_FreeSurface(ctx.surf);
--     SDL_FreeSurface(empty);

--     SDL_Quit();

--     return 0;
-- }
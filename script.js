document.addEventListener('DOMContentLoaded', () => {
    const videos = document.querySelectorAll('.bg-video');
    let currentIndex = 0;
    const displayDuration = 5000; // 5 seconds per video

    if (videos.length === 0) return;

    // Initialize first video
    const firstVideo = videos[0];
    firstVideo.classList.add('active');

    // Start the loop
    scheduleNextVideo();

    function scheduleNextVideo() {
        setTimeout(() => {
            playNextVideo();
        }, displayDuration);
    }

    function playNextVideo() {
        const nextIndex = (currentIndex + 1) % videos.length;
        const nextVideo = videos[nextIndex];

        // Preload next video
        nextVideo.load();

        // Check if next video is ready to play
        if (nextVideo.readyState >= 3) { // HAVE_FUTURE_DATA
            switchVideo(nextVideo, nextIndex);
        } else {
            // If not ready, wait for it
            console.log(`Video ${nextIndex} buffering...`);
            nextVideo.addEventListener('canplay', function onCanPlay() {
                nextVideo.removeEventListener('canplay', onCanPlay);
                switchVideo(nextVideo, nextIndex);
            }, { once: true });
        }
    }

    function switchVideo(nextVideo, nextIndex) {
        // Switch active class
        videos[currentIndex].classList.remove('active');
        nextVideo.classList.add('active');

        // Play the new video
        nextVideo.play().catch(e => console.error("Play error:", e));

        // Update index
        currentIndex = nextIndex;

        // Schedule next switch
        scheduleNextVideo();
    }
});

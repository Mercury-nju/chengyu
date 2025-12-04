document.addEventListener('DOMContentLoaded', () => {
    const videos = document.querySelectorAll('.bg-video');
    let currentIndex = 0;
    const intervalTime = 5000; // 5 seconds

    // Ensure the first video is active initially
    if (videos.length > 0) {
        videos[0].classList.add('active');
    }

    function switchVideo() {
        // Remove active class from current video
        videos[currentIndex].classList.remove('active');

        // Calculate next index
        currentIndex = (currentIndex + 1) % videos.length;

        // Add active class to next video
        videos[currentIndex].classList.add('active');

        // Reset the video time to 0 when it becomes active to ensure it plays from start? 
        // Actually, for a background loop, letting it play or resetting are both fine.
        // Let's reset it to ensure we see the start of the clip if that's desired, 
        // but for smooth ambience, maybe just letting it run is better if they are long.
        // However, the user said "switch every 5 seconds", and the videos might be longer.
        // Let's just toggle visibility. The 'autoplay loop' in HTML handles playback.
    }

    setInterval(switchVideo, intervalTime);
});

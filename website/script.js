document.addEventListener('DOMContentLoaded', () => {
    const videos = document.querySelectorAll('.bg-video');
    let currentIndex = 0;
    const intervalTime = 5000; // 5 seconds

    // Ensure the first video is active initially and wait for it to load
    if (videos.length > 0) {
        const firstVideo = videos[0];

        // Add loading event listener
        firstVideo.addEventListener('loadeddata', () => {
            console.log('First video loaded and ready to play');
            firstVideo.classList.add('active');
        });

        // If video is already loaded (cached), activate it immediately
        if (firstVideo.readyState >= 2) {
            firstVideo.classList.add('active');
        }

        // Preload the next video
        if (videos.length > 1) {
            videos[1].load();
        }
    }

    function switchVideo() {
        // Remove active class from current video
        videos[currentIndex].classList.remove('active');

        // Calculate next index
        currentIndex = (currentIndex + 1) % videos.length;

        // Add active class to next video
        const nextVideo = videos[currentIndex];
        nextVideo.classList.add('active');

        // Preload the video after next
        const preloadIndex = (currentIndex + 1) % videos.length;
        if (videos[preloadIndex]) {
            videos[preloadIndex].load();
        }
    }

    // Start the carousel after a delay to ensure first video is visible
    setTimeout(() => {
        setInterval(switchVideo, intervalTime);
    }, 1000);
});

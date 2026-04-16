module.exports = (io) => {
    const trackingNamespace = io.of('/tracking');
    trackingNamespace.on('connection', (socket) => {
        console.log(`Tracking Client Connected: ${socket.id}`);
        
        let lat = 12.9715987;
        let lng = 77.5945627;
        const interval = setInterval(() => {
            lat += 0.0001;
            lng += 0.0001;
            socket.emit('location_update', { lat, lng, timestamp: Date.now() });
        }, 5000);

        socket.on('disconnect', () => {
            clearInterval(interval);
            console.log(`Tracking Client Disconnected: ${socket.id}`);
        });
    });
};

module.exports = (io) => {
    const vitalsNamespace = io.of('/vitals');
    vitalsNamespace.on('connection', (socket) => {
        console.log(`Vitals Client Connected: ${socket.id}`);
        
        const interval = setInterval(() => {
            socket.emit('vitals_update', {
                heartRate: Math.floor(Math.random() * (120 - 60 + 1)) + 60,
                spO2: Math.floor(Math.random() * (100 - 95 + 1)) + 95,
                temperature: (Math.random() * (99.5 - 97.5) + 97.5).toFixed(1),
                respiratoryRate: Math.floor(Math.random() * (20 - 12 + 1)) + 12,
                glucose: Math.floor(Math.random() * (140 - 80 + 1)) + 80,
                ecgTimestamp: Date.now()
            });
        }, 3000);

        socket.on('disconnect', () => {
            clearInterval(interval);
            console.log(`Vitals Client Disconnected: ${socket.id}`);
        });
    });
};

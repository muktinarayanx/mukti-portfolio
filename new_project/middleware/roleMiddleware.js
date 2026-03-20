const User = require('../models/User');

const adminOnly = async (req, res, next) => {
    try {
        if (!req.user) {
            return res.status(401).json({ message: 'Not authorized, no user data found' });
        }

        if (req.user.role !== 'owner') {
            return res.status(403).json({ message: 'Access denied: Owner role required' });
        }

        next();
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error authorizing role' });
    }
};

module.exports = { adminOnly };

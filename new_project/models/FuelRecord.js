const mongoose = require('mongoose');

const fuelRecordSchema = new mongoose.Schema({
    date: {
        type: Date,
        required: true,
        default: Date.now
    },
    vehicleNumber: {
        type: String,
        required: true,
        trim: true,
        uppercase: true
    },
    litres: {
        type: Number,
        required: true,
        min: 0.1
    },
    pricePerLitre: {
        type: Number,
        required: true,
        min: 0.1
    },
    instructorName: {
        type: String,
        required: true,
        trim: true
    },
    totalAmount: {
        type: Number,
        required: true
    },
    createdBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    }
}, { timestamps: true });

module.exports = mongoose.model('FuelRecord', fuelRecordSchema);

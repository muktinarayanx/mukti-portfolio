const FuelRecord = require('../models/FuelRecord');
const PDFDocument = require('pdfkit');

// @desc    Add a fuel record
// @route   POST /fuel/add
// @access  Private
const addFuelRecord = async (req, res) => {
    try {
        const { date, vehicleNumber, litres, pricePerLitre, instructorName } = req.body;

        if (!date || !vehicleNumber || !litres || !pricePerLitre || !instructorName) {
            return res.status(400).json({ message: 'Please provide all required fields' });
        }

        const totalAmount = parseFloat(litres) * parseFloat(pricePerLitre);

        const record = await FuelRecord.create({
            date,
            vehicleNumber,
            litres,
            pricePerLitre,
            instructorName,
            totalAmount,
            createdBy: req.user._id
        });

        res.status(201).json(record);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Get all fuel records globally (Admin/Owner)
// @route   GET /fuel/global
// @access  Private/Admin
const getAllSystemRecords = async (req, res) => {
    try {
        const records = await FuelRecord.find({}).sort({ createdAt: -1 });
        res.json(records);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Get all fuel records
// @route   GET /fuel/all
// @access  Private
const getFuelRecords = async (req, res) => {
    try {
        const records = await FuelRecord.find({ createdBy: req.user._id }).sort({ createdAt: -1 });
        res.json(records);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Delete a fuel record
// @route   DELETE /fuel/:id
// @access  Private
const deleteFuelRecord = async (req, res) => {
    try {
        const record = await FuelRecord.findById(req.params.id);

        if (!record) {
            return res.status(404).json({ message: 'Record not found' });
        }

        // Check for user
        if (record.createdBy.toString() !== req.user.id) {
            return res.status(401).json({ message: 'User not authorized' });
        }

        await record.deleteOne();
        res.status(200).json({ id: req.params.id });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error' });
    }
}

// @desc    Generate PDF Bill
// @route   GET /fuel/:id/bill
// @access  Private
const generateBill = async (req, res) => {
    try {
        const record = await FuelRecord.findById(req.params.id);

        if (!record) {
            return res.status(404).json({ message: 'Record not found' });
        }

        // Check for user authorization
        // Allowing any authenticated user to view to satisfy "Allow the same or another authenticated user to download/view the bill"
        // So we skip the createdBy check if we just want generally auth'd users.

        const doc = new PDFDocument({ margin: 50 });

        let filename = `Bill-${record._id}.pdf`;
        filename = encodeURIComponent(filename);

        res.setHeader('Content-disposition', `attachment; filename="${filename}"`);
        res.setHeader('Content-type', 'application/pdf');

        doc.pipe(res);

        // Build PDF (Professional Format)

        // --- Header Section ---
        doc.fontSize(24).font('Helvetica-Bold').text('Tirupati Balaji Construction', { align: 'center' });
        doc.moveDown(0.2);
        doc.fontSize(12).font('Helvetica').text('Owner: Vikash Kumar', { align: 'center' });
        doc.text('Add: Kab, Patna Pin: 801104', { align: 'center' });
        doc.moveDown(1);

        doc.moveTo(50, doc.y).lineTo(550, doc.y).lineWidth(1).stroke();
        doc.moveDown(1);

        doc.fontSize(16).font('Helvetica-Bold').text('FUEL TRANSACTION RECEIPT', { align: 'center' });
        doc.moveDown(2);

        // --- Receipt logic ---
        const vNum = record.vehicleNumber || "";
        // Remove spaces and special characters for a clean string
        const cleanVNum = vNum.replace(/[^a-zA-Z0-9]/g, '');
        // Grab exactly the last 6 alphanumeric characters
        const lastSix = cleanVNum.slice(-6).toUpperCase();

        // Use real-time creation standard for the receipt processing time
        const realTime = new Date();
        let hours = realTime.getHours();
        let minutes = realTime.getMinutes();
        const ampm = hours >= 12 ? 'PM' : 'AM';

        // Convert to 12-hour format properly
        hours = hours % 12;
        hours = hours ? hours : 12;

        // Pad minutes with a zero if needed
        minutes = minutes < 10 ? '0' + minutes : minutes;

        const timeStr = `${hours}${minutes}${ampm}`;
        const receiptNo = `${lastSix}-${timeStr}`;

        // --- Details Section ---
        doc.fontSize(12).font('Helvetica');
        const detailsY = doc.y;

        // Left 
        doc.text(`Receipt No : ${receiptNo}`, 50, detailsY);
        doc.text(`Date : ${new Date(record.date).toLocaleDateString()}`, 50, detailsY + 25);

        // Check if the requester is an Owner. We appended req.user during auth middleware.
        const printInstructor = req.user.role === 'owner' ? 'Owner' : record.instructorName;

        // Right
        doc.text(`Instructor : ${printInstructor}`, 400, detailsY);
        doc.text(`Vehicle No : ${record.vehicleNumber}`, 400, detailsY + 25);

        doc.moveDown(4);

        // --- Items Section (Simple Linear) ---
        let itemY = doc.y;
        doc.font('Helvetica-Bold').text('Description', 50, itemY);
        doc.font('Helvetica').text('Fuel (Diesel/Petrol)', 200, itemY);

        itemY += 25;
        doc.font('Helvetica-Bold').text('Litres Filled', 50, itemY);
        doc.font('Helvetica').text(`${record.litres.toFixed(2)} L`, 200, itemY);

        itemY += 25;
        doc.font('Helvetica-Bold').text('Rate per Litre', 50, itemY);
        doc.font('Helvetica').text(`RS ${record.pricePerLitre.toFixed(2)}`, 200, itemY);

        itemY += 30;
        doc.moveTo(50, itemY).lineTo(550, itemY).lineWidth(0.5).stroke();

        // --- Totals Section ---
        itemY += 15;
        doc.fontSize(14).font('Helvetica-Bold');
        doc.text('Total Amount Paid :', 250, itemY);
        doc.text(`RS ${record.totalAmount.toFixed(2)}`, 400, itemY);

        itemY += 50;

        // --- Footer Notes ---
        doc.fontSize(10).font('Helvetica-Oblique').text('Thank you for your business!', 50, itemY, { align: 'center' });
        doc.text('This is a computer-generated receipt and requires no signature.', { align: 'center' });

        doc.end();
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error' });
    }
};

module.exports = {
    addFuelRecord,
    getFuelRecords,
    getAllSystemRecords,
    deleteFuelRecord,
    generateBill
};

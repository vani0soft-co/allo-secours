const { DataTypes } = require('sequelize');
const sequelize = require('./index');

const Review = sequelize.define('Review', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    serviceId: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    userId: {
        type: DataTypes.INTEGER,
        allowNull: true,
    },
    userName: {
        type: DataTypes.STRING(200),
        allowNull: false,
    },
    rating: {
        type: DataTypes.FLOAT,
        allowNull: false,
        validate: { min: 1, max: 5 },
    },
    comment: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
    likeCount: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
}, {
    tableName: 'reviews',
    timestamps: true,
});

module.exports = Review;

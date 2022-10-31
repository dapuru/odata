module.exports = srv => {
    srv.on('READ', 'Products', async (req, next) => {
        const items = await next()
        return items.filter(item => item.UnitsInStock > 100)
    })
}

export default {
  name: 'product',
  type: 'document',
  title: 'Product',
  fields: [
    { name: 'name', title: 'Name', type: 'string' },
    { name: 'sku', title: 'SKU', type: 'string' },
    { name: 'description', title: 'Description', type: 'text' },
    { name: 'price', title: 'Price', type: 'number' },
    { name: 'category', title: 'Category', type: 'string' },
    { name: 'subType', title: 'Sub Type', type: 'string' },
    {
      name: 'imageUrl',
      title: 'Main Image',
      type: 'image',
      options: { hotspot: true },
    },
    {
      name: 'features',
      title: 'Features',
      type: 'array',
      of: [{ type: 'string' }],
    },
    { name: 'stockQuantity', title: 'Stock Quantity', type: 'number' },
    { name: 'colorName', title: 'Color Name', type: 'string' },
    { name: 'hasSameDayDelivery', title: 'Same Day Delivery', type: 'boolean' },
  ],
};

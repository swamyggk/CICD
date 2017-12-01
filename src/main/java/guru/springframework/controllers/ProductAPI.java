/*
 *  Copyright 2017 Fortna, Inc.
 */
package guru.springframework.controllers;

import guru.springframework.domain.Product;
import guru.springframework.domain.dto.ProductExtraDto;
import guru.springframework.services.ProductService;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

/**
 *
 * @author Tho Nguyen <thonguyen@fortna.com>
 */
@RestController
@RequestMapping(value = "/api/product", produces = "application/json")
public class ProductAPI {

    @Value("${product.master.url}")
    private String productMasterUrl;

    private ProductService productService;

    RestTemplate restTemplate;

    protected RestTemplate getRestTemplate() {
        if (restTemplate == null) {
            restTemplate = new RestTemplate();
        }
        return restTemplate;
    }

    protected String getRemoteURL(String uri) {
        String ppProtocol = "http";
        StringBuilder strBuffer = new StringBuilder();
        strBuffer.append(ppProtocol);
        strBuffer.append("://").append(uri).append(uri);
        return strBuffer.toString();
    }

    @Autowired
    public void setProductService(ProductService productService) {
        this.productService = productService;
    }

    private ProductExtraDto getProductInfo(String id) {
        ProductExtraDto result = getRestTemplate().getForObject(getRemoteURL(productMasterUrl), ProductExtraDto.class);
        return result;
    }

    @RequestMapping(value = "/list", method = RequestMethod.GET)
    public ResponseEntity<List<Product>> listAllProducts() {
        List<Product> products = productService.listAll();

        if (products.isEmpty()) {
            return new ResponseEntity(HttpStatus.NO_CONTENT);
            // You many decide to return HttpStatus.NOT_FOUND
        }
        return new ResponseEntity<>(products, HttpStatus.OK);
    }

    @RequestMapping(value = "/{id}", method = RequestMethod.GET)
    public ResponseEntity<Product> getProduct(@PathVariable("id") long id) {
        Product product = productService.getById(id);

        if (product == null) {
            return new ResponseEntity(HttpStatus.NO_CONTENT);
        }
        return new ResponseEntity<>(product, HttpStatus.OK);
    }
}

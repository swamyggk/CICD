/*
 *  Copyright 2017 Fortna, Inc.
 */
package guru.springframework.domain.dto;

/**
 *
 * @author Tho Nguyen <thonguyen@fortna.com>
 */
public class ProductExtraDto {

    String location;
    String sku;

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

}
